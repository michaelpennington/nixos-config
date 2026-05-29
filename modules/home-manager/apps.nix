{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
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
