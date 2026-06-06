{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/wireguard.nix
  ];

  networking.hostName = "hermes";

  my.wireguard = let
    wgKeys = import ../wireguard-keys.nix;
  in {
    enable = true;
    ip = "10.100.0.1/24";
    peers = [
      {
        # Artemis
        publicKey = wgKeys.artemis;
        allowedIPs = ["10.100.0.2/32"];
      }
      {
        # Poseidon
        publicKey = wgKeys.poseidon;
        allowedIPs = ["10.100.0.3/32"];
      }
    ];
  };

  nixpkgs.config.allowUnfree = true;

  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Enable basic Nginx web server
  services.nginx = {
    enable = true;

    # Example basic virtual host configuration
    virtualHosts."default" = {
      default = true;
      root = pkgs.writeTextDir "index.html" "<h1>Hello from Hermes!</h1>";
      locations."/" = {
        index = "index.html";
      };
      locations."/guacamole/" = {
        proxyPass = "http://10.100.0.3:8080/guacamole/";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_buffering off;
        '';
      };
    };
  };

  # Open HTTP and HTTPS ports in the firewall
  networking.firewall.allowedTCPPorts = [80 443];

  system.stateVersion = "24.05";
}
