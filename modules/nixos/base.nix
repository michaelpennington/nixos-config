{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  # Networking and Localization
  networking.networkmanager.enable = true;

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  # User Account Management
  users = {
    users = {
      # Primary user account
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
        ];
      };

      # LFS (Linux From Scratch) dedicated user
      lfs = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "networkmanager"
          "lfs"
        ];
      };
    };

    # System groups
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

  # Nix Package Manager Configuration
  nix = {
    # Garbage collection and optimization
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 1w";
    };

    # Store settings and experimental features
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

  # Essential System Packages
  environment.systemPackages = with pkgs; [
    lm_sensors
    lz4
    pciutils
    file
    zip
    unzip
    bottom
    eza
    fd
    screen
    ripgrep
    parallel
    usbutils
    stow
    w3m
    wget
    xdg-user-dirs
  ];

  # System Services
  services = {
    fstrim.enable = true;

    # CUPS Printing Service
    printing = {
      enable = true;
      allowFrom = ["all"];
      browsing = true;
      defaultShared = true;
      openFirewall = true;
    };

    # Avahi for local network discovery
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    openssh.enable = true;
  };

  # Virtualization
  virtualisation.docker.enable = true;
}
