{ config, pkgs, lib, ... }:

let
  cfg = config.my.guacamole;
  backend = config.virtualisation.oci-containers.backend;
  backendBin = if backend == "podman" then "${pkgs.podman}/bin/podman" else "${pkgs.docker}/bin/docker";
in {
  options.my.guacamole = {
    enable = lib.mkEnableOption "Enable Apache Guacamole via OCI Containers";
    bindIp = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "The IP address to bind the Guacamole client to (e.g. Wireguard IP).";
    };
  };

  config = lib.mkIf cfg.enable {
    # Ensure a dedicated network exists for Guacamole components
    systemd.services.init-guac-network = {
      description = "Create OCI Network for Guacamole";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "oneshot";
      script = ''
        ${backendBin} network create guac-net || true
      '';
    };

    # Auto-initialize the Postgres database schema if it is empty
    systemd.services.init-guac-db = {
      description = "Initialize Guacamole Database Schema";
      after = [ "${backend}-guac-db.service" ];
      wants = [ "${backend}-guac-db.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "oneshot";
      script = ''
        # Wait for Postgres to be ready
        until ${backendBin} exec guac-db pg_isready -U guacamole; do
          sleep 2
        done

        # Check if tables exist
        TABLE_COUNT=$(${backendBin} exec guac-db psql -U guacamole -d guacamole -t -c "SELECT count(*) FROM information_schema.tables WHERE table_schema = 'public';" | tr -d ' ')
        
        if [ "$TABLE_COUNT" -eq 0 ]; then
          echo "Database is empty. Initializing schema..."
          ${backendBin} run --rm guacamole/guacamole:latest /opt/guacamole/bin/initdb.sh --postgresql > /tmp/initdb.sql
          cat /tmp/initdb.sql | ${backendBin} exec -i guac-db psql -U guacamole -d guacamole
          rm /tmp/initdb.sql
          
          # Restart the guacamole client container so it picks up the new schema
          ${pkgs.systemd}/bin/systemctl restart ${backend}-guacamole.service
          echo "Schema initialized!"
        else
          echo "Database already initialized."
        fi
      '';
    };

    # OCI Containers for the Guacamole Stack
    virtualisation.oci-containers.containers = {
      guacd = {
        image = "guacamole/guacd:latest";
        extraOptions = [ "--network=guac-net" ];
      };

      guac-db = {
        image = "postgres:15";
        environment = {
          POSTGRES_USER = "guacamole";
          POSTGRES_PASSWORD = "guacamole_password"; # Secure enough as it's isolated in the Docker network
          POSTGRES_DB = "guacamole";
          POSTGRES_HOST_AUTH_METHOD = "trust";
        };
        volumes = [
          "guac-db-data:/var/lib/postgresql/data"
        ];
        extraOptions = [ "--network=guac-net" ];
      };

      guacamole = {
        image = "guacamole/guacamole:latest";
        environment = {
          GUACD_HOSTNAME = "guacd";
          POSTGRESQL_HOSTNAME = "guac-db";
          POSTGRESQL_DATABASE = "guacamole";
          POSTGRESQL_USER = "guacamole";
          POSTGRESQL_PASSWORD = "guacamole_password";
        };
        ports = [
          "${cfg.bindIp}:8080:8080"
        ];
        dependsOn = [ "guacd" "guac-db" ];
        extraOptions = [ "--network=guac-net" ];
      };
    };
  };
}
