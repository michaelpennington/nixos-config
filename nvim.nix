{ config, lib, pkgs, ... }:

with lib;
let
  build-dependent-pkgs = with pkgs;
    [
      acl
      attr
      bzip2
      curl
      libsodium
      libssh
      libxml2
      openssl
      stdenv.cc.cc
      systemd
      util-linux
      xz
      zlib
      zstd
      glib
      libcxx
    ];

  makePkgConfigPath = x: makeSearchPathOutput "dev" "lib/pkgconfig" x;
  makeIncludePath = x: makeSearchPathOutput "dev" "include" x;

  nvim-depends-library = pkgs.buildEnv {
    name = "nvim-depends-library";
    paths = map lib.getLib build-dependent-pkgs;
    extraPrefix = "/lib/nvim-depends";
    pathsToLink = [ "/lib" ];
    ignoreCollisions = true;
  };
  nvim-depends-include = pkgs.buildEnv {
    name = "nvim-depends-include";
    paths = splitString ":" (makeIncludePath build-dependent-pkgs);
    extraPrefix = "/lib/nvim-depends/include";
    ignoreCollisions = true;
  };
  nvim-depends-pkgconfig = pkgs.buildEnv {
    name = "nvim-depends-pkgconfig";
    paths = splitString ":" (makePkgConfigPath build-dependent-pkgs);
    extraPrefix = "/lib/nvim-depends/pkgconfig";
    ignoreCollisions = true;
  };
  buildEnv = [
    "CPATH=${config.home.profileDirectory}/lib/nvim-depends/include"
    "CPLUS_INCLUDE_PATH=${config.home.profileDirectory}/lib/nvim-depends/include/c++/v1"
    "LD_LIBRARY_PATH=${config.home.profileDirectory}/lib/nvim-depends/lib"
    "LIBRARY_PATH=${config.home.profileDirectory}/lib/nvim-depends/lib"
    "NIX_LD_LIBRARY_PATH=${config.home.profileDirectory}/lib/nvim-depends/lib"
    "PKG_CONFIG_PATH=${config.home.profileDirectory}/lib/nvim-depends/pkgconfig"
  ];
  nvimConfigPath = "${config.home.homeDirectory}/nixos-config/nvim";
in {
  home.packages = with pkgs; [
    patchelf
    nvim-depends-include
    nvim-depends-library
    nvim-depends-pkgconfig
    ripgrep
  ];
  home.extraOutputsToInstall = ["nvim-depends"];

  programs.neovim = {
    enable = true;
    # package = pkgs.neovim;

    withNodeJs = true;
    withPython3 = true;
    withRuby = true;

    initLua = ''
      vim.opt.rtp:prepend(${nvimConfigPath})

      dofile("${nvimConfigPath}/init.lua")
    '';

    extraWrapperArgs = [
      "--suffix"
      "CPATH"
      "${config.home.profileDirectory}/lib/nvim-depends/include"
      ":"
      "--suffix"
      "CPLUS_INCLUDE_PATH"
      "${config.home.profileDirectory}/lib/nvim-depends/include/c++/v1"
      ":"
      "--suffix"
      "LD_LIBRARY_PATH"
      "${config.home.profileDirectory}/lib/nvim-depends/lib"
      ":"
      "--suffix"
      "LIBRARY_PATH"
      "${config.home.profileDirectory}/lib/nvim-depends/lib"
      ":"
      "--suffix"
      "NIX_LD_LIBRARY_PATH"
      "${config.home.profileDirectory}/lib/nvim-depends/lib"
      ":"
      "--suffix"
      "PKG_CONFIG_PATH"
      "${config.home.profileDirectory}/lib/nvim-depends/pkgconfig"
      ":"
      "--suffix"
      "SQLITE_CLIB_PATH"
      "${pkgs.sqlite.out}/lib/libsqlite3.so"
      ":"
    ];

    extraPackages = with pkgs;
      [
        doq
        sqlite
        cargo
        clang
        cmake
        gcc
        gnumake
        ninja
        pkg-config
        yarn
      ];
    defaultEditor = true;

    extraLuaPackages = ls: with ls; [ luarocks ];
  };
}
