{
  config,
  pkgs,
  ...
}: {
  # Local Development Services
  services.mysql = {
    enable = true;
    package = pkgs.mariadb; # Use MariaDB as the MySQL implementation
  };
}
