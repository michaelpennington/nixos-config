{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  networking.networkmanager.enable = true;

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
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
        ];
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
    lz4
    pciutils
    bat
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

  services = {
    fstrim.enable = true;
    printing = {
      enable = true;
      allowFrom = ["all"];
      browsing = true;
      defaultShared = true;
      openFirewall = true;
    };
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    openssh.enable = true;
  };

  virtualisation.docker.enable = true;
}
