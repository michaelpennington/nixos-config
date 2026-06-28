{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  # User Application Suites
  home.packages = with pkgs; [
    # Media & Entertainment
    (mpv.override {
      scripts = [
        mpvScripts.eisa01.simplebookmark
      ];
    })
    freetube
    vlc
    spotdl
    pianoteq-routed
    ardour

    # Internet & Communication
    chromium
    tor-browser
    zoom-us

    # Development & System Tools
    alsa-utils
    alejandra
    taplo
    colmena
    packwiz
    gemini-cli
    aoc-cli
    mesa-demos
    vulkan-tools
    aha
    appimage-run
    file-roller
    baobab

    # Hardware & Driver Specific Tools
    latest-alsa-scarlett-gui
    latest-scarlett2-firmware
    latest-scarlett2-cli
    libmtp
    v4l-utils
    system-config-printer

    # Productivity & Creative
    emacs-pgtk
    gimp
    obs-studio
    lilypond-with-fonts
    libreoffice-fresh
    nautilus

    # Gaming
    forge-mtg

    # Miscellaneous
    protonup-rs # Steam/Proton management
    flatpak
    wkhtmltopdf
    qbittorrent
  ];

  # Browser Configuration
  programs.firefox = {
    enable = true;
    languagePacks = ["en-US"];
    configPath = "${config.xdg.configHome}/mozilla/firefox";
  };
}
