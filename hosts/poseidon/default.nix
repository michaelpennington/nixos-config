{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    inputs.ucodenix.nixosModules.default
    inputs.nix-minecraft.nixosModules.minecraft-servers
    inputs.probe-rs-rules.nixosModules.x86_64-linux.default
    inputs.musnix.nixosModules.musnix
    ../../modules/nixos/base.nix
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/audio.nix
    ../../modules/nixos/gaming.nix
    ../../modules/nixos/dev.nix
  ];

  networking.hostName = "poseidon";

  nixpkgs.overlays = [
    inputs.nix-minecraft.overlay
    inputs.self.overlays.default
  ];
  nixpkgs.config.allowUnfree = true;

  boot = {
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
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 20;
      };
      efi.canTouchEfiVariables = true;
    };
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
  time.hardwareClockInLocalTime = true;

  hardware.amdgpu.overdrive.enable = true;

  services.ucodenix = {
    enable = true;
    cpuModelId = "00A60F12";
  };

  services.udev.extraRules = ''
    # Set 'none' (noop) scheduler for all NVMe devices
    ACTION=="add|change", KERNEL=="nvme[0-9]*n[0-9]*", ATTR{queue/scheduler}="none"

    # Optional: Do the same for any non-rotational SATA devices (SSDs)
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="none"

    SUBSYSTEM=="usb", ATTRS{idVendor}=="303a", ATTRS{idProduct}=="1001", MODE="0660", GROUP="dialout", TAG+="uaccess"
  '';

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;
    }
  ];

  system.stateVersion = "24.05";
}
