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
    inputs.nix-minecraft.nixosModules.minecraft-servers
    inputs.probe-rs-rules.nixosModules.x86_64-linux.default
    inputs.musnix.nixosModules.musnix

    # Shared system modules
    ../../modules/nixos/base.nix
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/audio.nix
    ../../modules/nixos/gaming.nix
    ../../modules/nixos/dev.nix
    ../../modules/nixos/wireguard.nix
    ../../modules/nixos/guacamole.nix
  ];

  # Basic networking configuration
  networking.hostName = "poseidon";

  my.guacamole = {
    enable = true;
    bindIp = "10.100.0.3";
  };

  age.secrets."hermes-ip" = {
    file = ../../secrets/hermes-ip.age;
    owner = "root";
    mode = "0400";
  };

  my.wireguard = let
    wgKeys = import ../wireguard-keys.nix;
  in {
    enable = true;
    ip = "10.100.0.3/24";
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
    inputs.nix-minecraft.overlay
    inputs.self.overlays.default
  ];
  nixpkgs.config.allowUnfree = true;

  # Bootloader and Kernel configuration
  boot = {
    # binfmt registrations for cross-architecture emulation (RISC-V)
    binfmt = {
      preferStaticEmulators = true;
      registrations.riscv64 = {
        interpreter = "${pkgs.pkgsStatic.qemu-user}/bin/qemu-riscv64";
        magicOrExtension = "\\x7fELF\\x02\\x01\\x01\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x02\\x00\\xf3\\x00";
        mask = "\\xff\\xff\\xff\\xff\\xff\\xff\\xff\\x00\\xff\\xff\\xff\\xff\\xff\\xff\\xff\\xff\\xfe\\xff\\xff\\xff";
        fixBinary = true;
        wrapInterpreterInShell = false;
      };
    };

    # Systemd-boot configuration
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 20;
      };
      efi.canTouchEfiVariables = true;
    };

    # Kernel parameters and optimizations
    kernelParams = [
      "amd_pstate=guided"
      "microcode.amd_sha_check=off"
      "acpi_enforce_resources=lax"
      "usbcore.autosuspend=-1"
    ];
    extraModprobeConfig = ''
      options it87 force_id=0x8628 ignore_resource_conflict=1
    '';
    kernel.sysctl = {
      "vm.vfs_cache_pressure" = 50;
    };
  };

  # Hardware and timing
  time.hardwareClockInLocalTime = true;
  hardware.amdgpu.overdrive.enable = true;

  # Specialized services
  services.ucodenix = {
    enable = true;
    cpuModelId = "00A60F12";
  };

  age.secrets."hermes-ssh" = {
    file = ../../secrets/hermes-ssh.age;
    owner = "mpennington";
    mode = "0400";
  };

  # Udev rules for hardware-specific behavior
  services.udev.extraRules = ''
    # Set 'none' (noop) scheduler for all NVMe devices
    ACTION=="add|change", KERNEL=="nvme[0-9]*n[0-9]*", ATTR{queue/scheduler}="none"

    # Optional: Do the same for any non-rotational SATA devices (SSDs)
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="none"

    # ESP32/Serial device access
    SUBSYSTEM=="usb", ATTRS{idVendor}=="303a", ATTRS{idProduct}=="1001", MODE="0660", GROUP="dialout", TAG+="uaccess"
  '';

  # Storage configuration
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;
    }
  ];

  # System state version
  system.stateVersion = "24.05";
}
