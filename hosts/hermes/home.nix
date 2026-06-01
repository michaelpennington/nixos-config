{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: let
  # Import and apply the Neovim module with inputs
  module = inputs.nixpkgs.lib.modules.importApply ../../modules/neovim.nix inputs;
  # Evaluate the Neovim module using nix-wrapper-modules
  evaluated = inputs.nix-wrapper-modules.lib.evalModule module;
in {
  imports = [
    evaluated.config.install
    ../../modules/home-manager/base.nix
  ];

  home.username = "mpennington";
  home.homeDirectory = "/home/mpennington";
  home.stateVersion = "24.05";

  wrappers.neovim.enable = true;

  xdg.enable = true;
}
