{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  # Desktop Hardware Support
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    probe-rs.enable = true;
    keyboard.qmk.enable = true;
  };

  # Display and Login Management
  services = {
    displayManager = {
      # Lightweight terminal-based login manager
      lemurs = {
        enable = true;
        settings = {
          environment_switcher.include_tty_shell = true;
        };
      };
    };

    # Secret and credential management
    gnome.gnome-keyring.enable = true;
  };

  # Typography and Iconography
  fonts.packages = with pkgs; [
    fantasque-sans-mono
    fira-code
    fira-code-symbols
    julia-mono
    source-code-pro
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji

    # Nerd Font patches for icons
    nerd-fonts.fantasque-sans-mono
    nerd-fonts.fira-code
  ];

  # Core Desktop Programs
  programs = {
    corectrl.enable = true; # AMD GPU/CPU performance control
    sway.enable = true; # Tiling Wayland compositor
    fish.enable = true; # Modern user shell
    git.enable = true;
    tmux.enable = true;
  };

  # XDG Portal for Wayland interoperability
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

  # Real-time and privilege management
  security = {
    rtkit.enable = true;
    polkit.enable = true;
  };
}
