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
  # Home Manager module imports
  imports = [
    # The Neovim wrapper installation output
    evaluated.config.install

    # Shared Home Manager modules
    ../../modules/home-manager/base.nix
    ../../modules/home-manager/desktop.nix
    ../../modules/home-manager/apps.nix
  ];

  # User identity and environment
  home.username = "mpennington";
  home.homeDirectory = "/home/mpennington";
  home.stateVersion = "24.05";

  # Neovim wrapper configuration
  wrappers.neovim.enable = true;

  # XDG base directory specification support
  xdg.enable = true;
}
