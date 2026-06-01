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

  system.stateVersion = "24.05";
}
