{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: let
  module = inputs.nixpkgs.lib.modules.importApply ./neovim.nix inputs;

  evaluated = inputs.nix-wrapper-modules.lib.evalModule module;
  factorio = pkgs.factorio.override {
    username = "mpennington";
    token = "c0e189d9a31587e4f3a6aec0953ea9";
  };

  latest-scarlett2-firmware = pkgs.stdenv.mkDerivation rec {
    pname = "scarlett2-firmware";
    version = "1.1";
    src = pkgs.fetchFromGitHub {
      owner = "geoffreybennett";
      repo = "scarlett2-firmware";
      rev = "${version}";
      sha256 = "sha256-IrhLFBXymiVGYenYP+v/IRWJqMIakWWQNaorHzPv/LM="; # Replace with actual hash
    };
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/lib/firmware/scarlett2
      cp firmware/*.bin $out/lib/firmware/scarlett2/
    '';
  };
  latest-alsa-scarlett-gui = pkgs.alsa-scarlett-gui.overrideAttrs (oldAttrs: rec {
    version = "1.0beta9";
    src = pkgs.fetchFromGitHub {
      owner = "geoffreybennett";
      repo = "alsa-scarlett-gui";
      rev = "${version}";
      sha256 = "sha256-PAQj8Jamu2MY1wGLnaWnvm9OfsXE0YTSDhfiaQLajB8=";
    };
    postPatch = ''
      substituteInPlace scarlett2-firmware.h \
        --replace-fail '"/usr/lib/firmware/scarlett2"' '"${latest-scarlett2-firmware}/lib/firmware/scarlett2"'
    '';
  });
  latest-scarlett2-cli = pkgs.stdenv.mkDerivation rec {
    pname = "scarlett2-cli";
    version = "1.0";
    src = pkgs.fetchFromGitHub {
      owner = "geoffreybennett";
      repo = "scarlett2";
      rev = "${version}";
      sha256 = "sha256-GfWfIOQfH5SoBdExIT1p/OHXJG2pwzTW/RS8Rs4QSGQ=";
    };

    nativeBuildInputs = [pkgs.pkg-config];
    buildInputs = [pkgs.alsa-lib pkgs.openssl];
    postPatch = ''
      substituteInPlace main.c \
        --replace-fail '"/usr/lib/firmware/scarlett2"' '"${latest-scarlett2-firmware}/lib/firmware/scarlett2"'
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp scarlett2 $out/bin
    '';
  };
in {
  imports = [evaluated.config.install];

  home.username = "mpennington";
  home.homeDirectory = "/home/mpennington";

  home.stateVersion = "24.05";

  wrappers.neovim.enable = true;

  home.packages = with pkgs; [
    # extractpdfmark
    (mpv.override {
      scripts = [
        mpvScripts.eisa01.simplebookmark
      ];
    })
    alsa-utils
    latest-alsa-scarlett-gui
    latest-scarlett2-firmware
    latest-scarlett2-cli
    emacs-pgtk
    inputs.pianoteq.packages.${pkgs.stdenv.hostPlatform.system}.default
    arduino-ide
    gimp
    # azure-cli
    protonup-rs

    # azure-storage-azcopy
    factorio
    wl-clipboard
    qpwgraph
    ardour
    sov
    aoc-cli
    aria2
    ventoy
    # musescore
    termscp
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
    nchat
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
    # openscad
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
    wezterm
    jdk
    # krita
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
      settings."*" = {
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
      configPath = "${config.xdg.configHome}/mozilla/firefox";
    };
    home-manager.enable = true;
    waybar = {
      enable = true;
      systemd = {
        enable = true;
        targets = ["sway-session.target"];
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
      wezterm = lib.meta.getExe pkgs.wezterm;
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

  xdg.enable = true;
}
