{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  # Machine-specific module imports
  imports = [
    ./hardware-configuration.nix
    inputs.ucodenix.nixosModules.default
    inputs.probe-rs-rules.nixosModules.x86_64-linux.default

    # Shared system modules
    ../../modules/nixos/base.nix
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/dev.nix
    ../../modules/nixos/wireguard.nix
  ];

  # Basic networking configuration
  networking.hostName = "artemis";

  age.secrets."hermes-ip" = {
    file = ../../secrets/hermes-ip.age;
    owner = "root";
    mode = "0400";
  };

  my.wireguard = let
    wgKeys = import ../wireguard-keys.nix;
  in {
    enable = true;
    ip = "10.100.0.2/24";
    hubEndpointFile = config.age.secrets."hermes-ip".path;
    hubPublicKey = wgKeys.hermes;
    peers = [
      {
        # Hermes (Hub)
        publicKey = wgKeys.hermes;
        allowedIPs = ["10.100.0.0/24"];
        persistentKeepalive = 25;
      }
    ];
  };

  # Package management and overlays
  nixpkgs.overlays = [
    inputs.self.overlays.default
  ];
  nixpkgs.config.allowUnfree = true;

  # Laptop Power Management
  services.power-profiles-daemon.enable = true;

  age.secrets."hermes-ssh" = {
    file = ../../secrets/hermes-ssh.age;
    owner = "mpennington";
    mode = "0400";
  };

  # Bootloader configuration (matching poseidon's simple systemd-boot for now)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # System state version
  system.stateVersion = "24.05";
}
