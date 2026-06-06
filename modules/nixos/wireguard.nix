{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.wireguard;
in {
  options.my.wireguard = {
    enable = lib.mkEnableOption "Enable Wireguard VPN";

    ip = lib.mkOption {
      type = lib.types.str;
      description = "The IP address (with CIDR) for this node on the wg0 interface.";
    };

    port = lib.mkOption {
      type = lib.types.int;
      default = 51820;
      description = "The UDP port for Wireguard to listen on.";
    };

    peers = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [];
      description = "List of peer configurations.";
    };

    hubEndpointFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to a file containing the hub's public IP address.";
    };

    hubPublicKey = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets."wg-private-${config.networking.hostName}" = {
      file = ../../secrets/wg-private-${config.networking.hostName}.age;
      owner = "root";
      mode = "0400";
    };

    networking.firewall.allowedUDPPorts = [cfg.port];
    networking.firewall.trustedInterfaces = [ "wg0" ];

    networking.wireguard.interfaces = {
      wg0 = {
        ips = [cfg.ip];
        listenPort = cfg.port;
        privateKeyFile = config.age.secrets."wg-private-${config.networking.hostName}".path;
        peers = cfg.peers;
        postSetup = lib.mkIf (cfg.hubEndpointFile != null && cfg.hubPublicKey != null) ''
          ${pkgs.wireguard-tools}/bin/wg set wg0 peer "${cfg.hubPublicKey}" endpoint "$(< ${cfg.hubEndpointFile}):${toString cfg.port}"
        '';
      };
    };
  };
}
