{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: let
  libbluray = pkgs.libbluray.override {
    withAACS = true;
    withBDplus = true;
    withJava = true;
  };
  vlc = pkgs.vlc.override {inherit libbluray;};
in {
  home.username = "mpennington";
  home.homeDirectory = "/home/mpennington";

  home.stateVersion = "24.05";

  home.packages = with pkgs; [
    alsa-utils
    aha
    chromium
    wkhtmltopdf
    kdenlive
    appimage-run
    file-roller
    freetube
    libmtp
    librecad
    mtpfs
    ffmpeg
    nodejs
    freecad
    super-slicer
    gtklp
    openscad
    spotdl
    slurp
    blender
    grim
    imv
    kicad
    inkscape
    fstl
    lilypond-with-fonts
    inputs.nixpkgs-stable.legacyPackages."${pkgs.system}".libreoffice-fresh
    # inputs.prismlauncher.packages."${pkgs.system}".prismlauncher
    inputs.wezterm.packages."${pkgs.system}".default
    jdk
    krita
    lazygit
    nautilus
    pavucontrol
    playerctl
    spotify-player
    sway-launcher-desktop
    swaynotificationcenter
    direnv
    vlc
    wlogout
    wob
    zathura
    zoom-us
    zoxide
  ];

  programs = {
    starship = {
      enable = true;
      settings = {
        time.disabled = false;
        time.use_12hr = true;
        time.style = ''#cfae71'';
      };
    };
    ssh.enable = true;
    firefox = {
      enable = true;
      languagePacks = ["en-US"];
    };
    home-manager.enable = true;
    waybar = {
      enable = true;
      systemd = {
        enable = true;
        target = "sway-session.target";
      };
    };
  };

  services = {
    lorri.enable = true;
    ssh-agent.enable = true;
  };

  wayland.windowManager.sway = {
    enable = true;
    checkConfig = false;
    extraConfig = builtins.readFile ./sway_config;
    systemd.enable = true;
    wrapperFeatures.gtk = true;
    config = let
      wezterm = lib.meta.getExe inputs.wezterm.packages."${pkgs.system}".default;
      swayLauncherDesktop = lib.meta.getExe pkgs.sway-launcher-desktop;
    in {
      bars = [];
      modifier = "Mod4";
      terminal = "${wezterm}";
      menu = "${wezterm} start --class \"launcher\" -- ${swayLauncherDesktop}";
      keybindings = let
        modifier = config.wayland.windowManager.sway.config.modifier;
        playerctl = lib.meta.getExe pkgs.playerctl;
        pactl = lib.meta.getExe' pkgs.pulseaudio "pactl";
        wlogout = lib.meta.getExe pkgs.wlogout;
      in
        lib.mkOptionDefault {
          "${modifier}+Shift+c" = "exec ${playerctl} play-pause";
          "${modifier}+Shift+v" = "exec ${playerctl} next";
          "${modifier}+Shift+x" = "exec ${playerctl} previous";
          "XF86AudioRaiseVolume" = "exec ${pactl} set-sink-volume @DEFAULT_SINK@ +5%";
          "XF86AudioLowerVolume" = "exec ${pactl} set-sink-volume @DEFAULT_SINK@ -5%";
          "${modifier}+Shift+p" = "reload";
          "${modifier}+Shift+e" = "exec ${wlogout}";
        };
      window = {
        border = 0;
        titlebar = false;
        commands = [
          {
            command = "floating enable, sticky enable, resize set 30ppt 60ppt, border pixel 5";
            criteria = {
              app_id = "^launcher$";
            };
          }
        ];
      };
      gaps = {
        inner = 15;
        outer = 20;
      };
      input = {
        "type:keyboard" = {
          repeat_delay = "300";
          repeat_rate = "30";
          xkb_options = "compose:ralt";
        };
      };
    };
  };

  xdg.enable = true;
}
