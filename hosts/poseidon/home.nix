{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: let
  module = inputs.nixpkgs.lib.modules.importApply ../../modules/neovim.nix inputs;
  evaluated = inputs.nix-wrapper-modules.lib.evalModule module;
in {
  imports = [
    evaluated.config.install
    ../../modules/home-manager/base.nix
    ../../modules/home-manager/desktop.nix
    ../../modules/home-manager/apps.nix
  ];

  home.username = "mpennington";
  home.homeDirectory = "/home/mpennington";
  home.stateVersion = "24.05";

  wrappers.neovim.enable = true;
  xdg.enable = true;
}
