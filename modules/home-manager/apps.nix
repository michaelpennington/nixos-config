{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: let
  pianoteqPkg = inputs.pianoteq.packages.${pkgs.stdenv.hostPlatform.system}.default;

  pianoteq-routed = pkgs.writeShellApplication {
    name = "pianoteq";
    runtimeInputs = [pkgs.pipewire];
    text = ''
      PTQ_BIN=$(find ${pianoteqPkg}/bin -type f -executable | head -n 1)
      PIPEWIRE_LATENCY="128/48000" PIPEWIRE_QUANTUM="128/48000" "$PTQ_BIN" "$@" &
      PID=$!
      PTQ_NODE="alsa_playback.pianoteq9"
      SCARLETT_NODE="alsa_output.usb-Focusrite_Scarlett_4i4_4th_Gen_S4G55AV578878D-00.pro-output-0"
      for _ in {1..20}; do
        if pw-link -o | grep -q "^$PTQ_NODE"; then
          break
        fi
        sleep 0.5
      done
      sleep 1
      mapfile -t PTQ_PORTS < <(pw-link -o | grep "^$PTQ_NODE")
      if [ ''${#PTQ_PORTS[@]} -ge 2 ]; then
        LEFT_OUT="''${PTQ_PORTS[0]}"
        RIGHT_OUT="''${PTQ_PORTS[1]}"
        pw-link -d "$LEFT_OUT" "$SCARLETT_NODE:playback_AUX0" 2>/dev/null || true
        pw-link -d "$RIGHT_OUT" "$SCARLETT_NODE:playback_AUX1" 2>/dev/null || true
        pw-link -d "$LEFT_OUT" "$SCARLETT_NODE:playback_AUX1" 2>/dev/null || true
        pw-link -d "$RIGHT_OUT" "$SCARLETT_NODE:playback_AUX2" 2>/dev/null || true
        pw-link "$LEFT_OUT" "$SCARLETT_NODE:playback_AUX2"
        pw-link "$RIGHT_OUT" "$SCARLETT_NODE:playback_AUX3"
      fi
      wait $PID
    '';
  };
  latest-scarlett2-firmware = pkgs.stdenv.mkDerivation rec {
    pname = "scarlett2-firmware";
    version = "1.1";
    src = pkgs.fetchFromGitHub {
      owner = "geoffreybennett";
      repo = "scarlett2-firmware";
      rev = "${version}";
      sha256 = "sha256-IrhLFBXymiVGYenYP+v/IRWJqMIakWWQNaorHzPv/LM=";
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
  home.packages = with pkgs; [
    (mpv.override {
      scripts = [
        mpvScripts.eisa01.simplebookmark
      ];
    })
    alsa-utils
    alejandra
    taplo
    colmena
    packwiz
    latest-alsa-scarlett-gui
    latest-scarlett2-firmware
    latest-scarlett2-cli
    emacs-pgtk
    pianoteq-routed
    gimp
    protonup-rs
    ardour
    aoc-cli
    flatpak
    aha
    mesa-demos
    vulkan-tools
    chromium
    wkhtmltopdf
    appimage-run
    file-roller
    freetube
    libmtp
    ffmpeg
    baobab
    v4l-utils
    obs-studio
    tor-browser
    gemini-cli
    gtklp
    spotdl
    lilypond-with-fonts
    libreoffice-fresh
    qbittorrent
    nautilus
    vlc
    zoom-us
  ];

  programs.firefox = {
    enable = true;
    languagePacks = ["en-US"];
    configPath = "${config.xdg.configHome}/mozilla/firefox";
  };
}
