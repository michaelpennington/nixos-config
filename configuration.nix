# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
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
  ];

  nixpkgs.overlays = [inputs.nix-minecraft.overlay];

  nixpkgs.config.allowUnfree = true;

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;
    }
  ];

  boot = {
    binfmt = {
      preferStaticEmulators = true;
      registrations.riscv64 = {
        # We use the static qemu-user binary
        interpreter = "${pkgs.pkgsStatic.qemu-user}/bin/qemu-riscv64";

        # Magic bytes for RISC-V 64-bit
        magicOrExtension = "\\x7fELF\\x02\\x01\\x01\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x02\\x00\\xf3\\x00";

        # Mask to ignore insignificant bytes
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

  virtualisation.docker.enable = true;

  hardware = {
    graphics.enable = true;
    amdgpu.overdrive.enable = true;
    probe-rs.enable = true;
  };

  networking.hostName = "poseidon";
  networking.networkmanager.enable = true;

  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; # use xkb.options in tty.
  };

  services = {
    displayManager = {
      lemurs = {
        enable = true;
        settings = {
          environment_switcher.include_tty_shell = true;
        };
      };
    };
    fstrim.enable = true;
    udev = {
      enable = true;
      extraRules = ''
        # Set 'none' (noop) scheduler for all NVMe devices
        ACTION=="add|change", KERNEL=="nvme[0-9]*n[0-9]*", ATTR{queue/scheduler}="none"

        # Optional: Do the same for any non-rotational SATA devices (SSDs)
        ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="none"

        SUBSYSTEM=="usb", ATTRS{idVendor}=="303a", ATTRS{idProduct}=="1001", MODE="0660", GROUP="dialout", TAG+="uaccess"
      '';
    };
    mysql = {
      enable = true;
      package = pkgs.mariadb;
    };
    printing = {
      enable = true;
      allowFrom = ["all"];
      browsing = true;
      defaultShared = true;
      openFirewall = true;
    };
    pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
    };
    ucodenix = {
      enable = true;
      cpuModelId = "00A60F12";
    };
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    openssh = {
      enable = true;
    };
    gnome.gnome-keyring.enable = true;
    minecraft-servers = {
      enable = true;
      eula = true;

      servers = {
        solo_world = let
          modpack = pkgs.fetchPackwizModpack {
            url = "https://github.com/michaelpennington/server_mods/raw/refs/heads/main/pack.toml";
            packHash = "sha256-/MfWEuhCzfBn/XbXVB/k2Em4XvM8SmnT71CKFfu3U+0=";
          };
          mcVersion = modpack.manifest.versions.minecraft;
          fabricVersion = modpack.manifest.versions.fabric;
          serverVersion = lib.replaceStrings ["."] ["_"] "fabric-${mcVersion}";
        in {
          enable = true;
          package = pkgs.fabricServers.${serverVersion}.override {
            loaderVersion = fabricVersion;
            jre_headless = pkgs.jdk25_headless;
          };
          autoStart = false;
          restart = "no";
          symlinks = {
            "mods" = "${modpack}/mods";
          };
          serverProperties = {
            # level-name = "Survival World";
            difficulty = "hard";
            pause-when-empty-seconds = -1;
            level-seed = 7137642459428857969;
          };
          files = {
            "config" = "${modpack}/config";
          };
          jvmOpts = "-Xms8G -Xmx12G -XX:+UseZGC -XX:+ZGenerational -XX:SoftMaxHeapSize=10g -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:+PerfDisableSharedMem -XX:+UseDynamicNumberOfGCThreads";
        };
      };
    };
  };
  musnix = {
    enable = true;
    kernel.realtime = true;
  };

  users = {
    users = {
      mpennington = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "networkmanager"
          "dialout"
          "audio"
          "video"
          "libvirtd"
          "seat"
          "input"
          "kvm"
          "adbuser"
          "plugdev"
          "docker"
        ]; # Enable ‘sudo’ for the user.
      };
      lfs = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "networkmanager"
          "lfs"
        ];
      };
    };
    groups = {
      plugdev = {
        members = ["mpennington"];
      };
      lfs = {
        name = "lfs";
        members = ["lfs"];
      };
    };
  };

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 1w";
    };
    settings = {
      auto-optimise-store = true;
      trusted-users = [
        "root"
        "mpennington"
      ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    lm_sensors
    amdgpu_top
    linuxPackages.zenpower
    radeontop
    lz4
    pciutils
    bat
    file
    zip
    unzip
    xmlstarlet
    bottom
    eza
    fd
    screen
    gh
    ripgrep
    parallel
    usbutils
    prismlauncher
    stow
    w3m
    wget
    xdg-user-dirs
  ];

  fonts.packages = with pkgs; [
    fantasque-sans-mono
    fira-code
    fira-code-symbols
    julia-mono
    source-code-pro
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    nerd-fonts.fantasque-sans-mono
    nerd-fonts.fira-code
  ];

  programs = {
    corectrl = {
      enable = true;
    };
    sway = {
      enable = true;
    };
    fish.enable = true;
    git.enable = true;
    tmux.enable = true;
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;

    extraPortals = [pkgs.xdg-desktop-portal-gtk];

    config = {
      sway = {
        default = lib.mkForce [
          "wlr"
          "gtk"
        ];
        "org.freedesktop.impl.portal.Secret" = [
          "gnome-keyring"
        ];
      };
    };
  };

  security = {
    rtkit.enable = true;
    polkit = {
      enable = true;
      extraConfig = ''
          polkit.addRule(function (action, subject) {
          if (
            subject.isInGroup("users") &&
            [
              "org.freedesktop.login1.reboot",
              "org.freedesktop.login1.reboot-multiple-sessions",
              "org.freedesktop.login1.power-off",
              "org.freedesktop.login1.power-off-multiple-sessions",
            ].indexOf(action.id) !== -1
          ) {
            return polkit.Result.YES;
          }
        });
      '';
    };
  };

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?
}
