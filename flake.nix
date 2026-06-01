{
  description = "A modular NixOS configuration with Haumea";

  # External dependencies and flake inputs
  inputs = {
    # Core NixOS packages and stable fallback
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";

    # haumea: For modular filesystem-based flake organization
    haumea = {
      url = "github:nix-community/haumea/v0.2.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # System-level modules and utilities
    musnix = {
      url = "github:musnix/musnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-wrapper-modules = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-minecraft = {
      url = "github:Infinidoge/nix-minecraft";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ucodenix.url = "github:e-tho/ucodenix";
    probe-rs-rules = {
      url = "github:jneem/probe-rs-rules";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Custom local packages
    pianoteq = {
      url = "path:./packages/pianoteq";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Neovim plugins and related tools
    plugins-lze = {
      url = "github:birdeehub/lze";
      flake = false;
    };
    plugins-lzextras = {
      url = "github:BirdeeHub/lzextras";
      flake = false;
    };
    plugins-kanagawa-paper-nvim = {
      url = "github:michaelpennington/kanagawa-paper.nvim";
      flake = false;
    };
    cargo-nvim = {
      url = "github:michaelpennington/cargo.nvim";
      flake = false;
    };
  };

  # Flake outputs generated using haumea to load the ./outputs directory
  outputs = inputs:
    inputs.haumea.lib.load {
      src = ./outputs;
      inputs = {
        inherit inputs;
        inherit (inputs.nixpkgs) lib;
      };
    };
}
