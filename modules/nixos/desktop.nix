{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  hardware = {
    graphics.enable = true;
    probe-rs.enable = true;
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
    gnome.gnome-keyring.enable = true;
  };

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
    corectrl.enable = true;
    sway.enable = true;
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
    polkit.enable = true;
  };
}
