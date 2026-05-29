{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: let
  module = inputs.nixpkgs.lib.modules.importApply ./neovim.nix inputs;

  evaluated = inputs.nix-wrapper-modules.lib.evalModule module;
  pianoteqPkg = inputs.pianoteq.packages.${pkgs.stdenv.hostPlatform.system}.default;

  # Create the wrapper script
  pianoteq-routed = pkgs.writeShellApplication {
    name = "pianoteq"; # Name it exactly what you want to type in the terminal/launcher
    runtimeInputs = [pkgs.pipewire]; # Ensures pw-link is available in the script
    text = ''
      # 1. Dynamically find the binary from your flake to avoid hardcoding the exact name
      PTQ_BIN=$(find ${pianoteqPkg}/bin -type f -executable | head -n 1)

      # 2. Launch Pianoteq in the background and capture its Process ID
      PIPEWIRE_LATENCY="128/48000" PIPEWIRE_QUANTUM="128/48000" "$PTQ_BIN" "$@" &
      PID=$!

      PTQ_NODE="alsa_playback.pianoteq9"
      SCARLETT_NODE="alsa_output.usb-Focusrite_Scarlett_4i4_4th_Gen_S4G55AV578878D-00.pro-output-0"

      # 3. Wait for Pianoteq's audio nodes to appear in PipeWire
      for _ in {1..20}; do
        if pw-link -o | grep -q "^$PTQ_NODE"; then
          break
        fi
        sleep 0.5
      done

      # Give WirePlumber exactly 1 second to apply its default routing so we can undo it
      sleep 1

      # 4. Get Pianoteq's exact output port names (usually playback_FL and FR, or playback_1 and 2)
      mapfile -t PTQ_PORTS < <(pw-link -o | grep "^$PTQ_NODE")

      if [ ''${#PTQ_PORTS[@]} -ge 2 ]; then
        LEFT_OUT="''${PTQ_PORTS[0]}"
        RIGHT_OUT="''${PTQ_PORTS[1]}"

        # 5. Sever the default connections
        # (Silently fails if they aren't connected, which is perfectly fine)
        pw-link -d "$LEFT_OUT" "$SCARLETT_NODE:playback_AUX0" 2>/dev/null || true
        pw-link -d "$RIGHT_OUT" "$SCARLETT_NODE:playback_AUX1" 2>/dev/null || true
        # Covering the AUX1/AUX2 offset you mentioned earlier just in case:
        pw-link -d "$LEFT_OUT" "$SCARLETT_NODE:playback_AUX1" 2>/dev/null || true
        pw-link -d "$RIGHT_OUT" "$SCARLETT_NODE:playback_AUX2" 2>/dev/null || true

        # 6. Force the connections we actually want
        pw-link "$LEFT_OUT" "$SCARLETT_NODE:playback_AUX2"
        pw-link "$RIGHT_OUT" "$SCARLETT_NODE:playback_AUX3"
      fi

      # 7. Keep the script alive so the terminal waits until you actually close Pianoteq
      wait $PID
    '';
  };
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
    pianoteq-routed
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
    terraform
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
    antigravity
    # freecad
    baobab
    v4l-utils
    obs-studio
    tor-browser
    super-slicer
    gemini-cli
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
    package = inputs.nixpkgs-stable.legacyPackages."x86_64-linux".sway;
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
        {command = "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP";}
        {command = "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway";}
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
