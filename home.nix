{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: let
  nvimPath = "${config.home.homeDirectory}/nixos-config/nvim";
in {
  imports = [./nvim.nix];

  home.username = "mpennington";
  home.homeDirectory = "/home/mpennington";

  home.stateVersion = "24.05";

  home.packages = with pkgs; [
    # extractpdfmark
    alsa-utils
    arduino-ide
    gimp
    azure-cli
    protonup-rs
    azure-storage-azcopy
    wl-clipboard
    sov
    aoc-cli
    aria2
    ventoy
    # musescore
    yt-dlp
    megasync
    polkit_gnome
    texlive.combined.scheme-full
    flatpak
    aha
    # megacli
    mesa-demos
    vulkan-tools
    yo
    haskell.compiler.ghc912
    chromium
    wkhtmltopdf
    # kdePackages.kdenlive
    appimage-run
    file-roller
    freetube
    libmtp
    librecad
    ffmpeg
    nodejs
    # freecad
    baobab
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
    libreoffice-fresh
    # inputs.prismlauncher.packages."${pkgs.stdenv.hostPlatform.system}".prismlauncher
    inputs.wezterm.packages."${pkgs.stdenv.hostPlatform.system}".default
    jdk
    krita
    lazygit
    qbittorrent
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
    ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks."*" = {
        forwardAgent = false;
        addKeysToAgent = "no";
        compression = false;
        serverAliveInterval = 0;
        serverAliveCountMax = 3;
        hashKnownHosts = false;
        userKnownHostsFile = "~/.ssh/known_hosts";
        controlMaster = "no";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "no";
      };
    };
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
    swayidle = let
      display = status: "${pkgs.sway}/bin/swaymsg 'output * power ${status}'";
    in {
      enable = true;
      timeouts = [
        {
          timeout = 300;
          command = display "off";
          resumeCommand = display "on";
        }
        {
          timeout = 1800;
          command = "${pkgs.systemd}/bin/systemctl suspend";
        }
      ];
      events = {
        "before-sleep" = display "off";
        "after-resume" = display "on";
        "lock" = display "off";
        "unlock" = display "on";
      };
    };
  };

  wayland.windowManager.sway = {
    enable = true;
    checkConfig = false;
    extraConfig = builtins.readFile ./sway_config;
    package = null;
    systemd.enable = true;
    wrapperFeatures.gtk = true;
    config = let
      wezterm = lib.meta.getExe inputs.wezterm.packages."${pkgs.stdenv.hostPlatform.system}".default;
      swayLauncherDesktop = lib.meta.getExe pkgs.sway-launcher-desktop;
    in {
      bars = [];
      modifier = "Mod4";
      terminal = "${wezterm}";
      menu = "${wezterm} start --class \"launcher\" -- ${swayLauncherDesktop}";
      startup = [
        {command = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";}
      ];
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

  xdg = {
    enable = true;
    configFile."nvim" = {
      recursive = false;
      source = config.lib.file.mkOutOfStoreSymlink nvimPath;
    };
  };
}
