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
  ];

  # Basic networking configuration
  networking.hostName = "artemis";

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
