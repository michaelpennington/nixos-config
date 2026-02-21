inputs:
{
  config,
  wlib,
  lib,
  pkgs,
  ...
}:
let
  myTreeSitter = (pkgs.tree-sitter.override { webUISupport = true; }).overrideAttrs (oldAttrs: rec {
    version = "0.26.5";
    src = pkgs.fetchFromGitHub {
      owner = "tree-sitter";
      repo = "tree-sitter";
      rev = "v0.26.5";
      fetchSubmodules = true;
      sha256 = "sha256-tnZ8VllRRYPL8UhNmrda7IjKSeFmmOnW/2/VqgJFLgU=";
    };
    cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
      inherit src;
      hash = "sha256-EU8kdG2NT3NvrZ1AqvaJPLpDQQwUhYG3Gj5TAjPYRsY=";
    };
    nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [
      pkgs.rustPlatform.bindgenHook
    ];
    postPatch = ''
      substituteInPlace crates/xtask/src/build_wasm.rs \
        --replace-fail 'let emcc_name = if cfg!(windows) { "emcc.bat" } else { "emcc" };' 'let emcc_name = "${lib.getExe' pkgs.emscripten "emcc"}";' \
        --replace-fail '"-gsource-map=inline",' ""
    '';
    preBuild = ''
      mkdir -p .emscriptencache
      export EM_CACHE=$(pwd)/.emscriptencache
      cargo run --package xtask -- build-wasm
    '';
  });
in
{
  imports = [ wlib.wrapperModules.neovim ];
  # NOTE: see the tips and tricks section or the bottom of this file + flake inputs to understand this value
  options.nvim-lib.neovimPlugins = lib.mkOption {
    readOnly = true;
    type = lib.types.attrsOf wlib.types.stringable;
    # Makes plugins autobuilt from our inputs available with
    # `config.nvim-lib.neovimPlugins.<name_without_prefix>`
    default = config.nvim-lib.pluginsFromPrefix "plugins-" inputs;
  };

  config.settings.config_directory = "/home/mpennington/nixos-config/nvim";

  config.specs.lze = [
    config.nvim-lib.neovimPlugins.lze
    {
      data = config.nvim-lib.neovimPlugins.lzextras;
      name = "lzextras";
    }
  ];

  config.specs.nix = {
    data = null;
    extraPackages = with pkgs; [
      nixd
      nixfmt
    ];
  };

  config.specs.lua = {
    after = [ "general" ];
    lazy = true;
    data = with pkgs.vimPlugins; [
      lazydev-nvim
    ];
    extraPackages = with pkgs; [
      lua-language-server
      stylua
    ];
  };

  config.specs.general = {
    after = [ "lze" ];
    lazy = true;

    extraPackages = with pkgs; [
      lazygit
      myTreeSitter
    ];

    data = with pkgs.vimPlugins; [
      barbar-nvim
      blink-cmp
      friendly-snippets
      gitsigns-nvim
      nvim-lspconfig
      nvim-treesitter
      nvim-treesitter-textobjects
      nvim-treesitter.withAllGrammars
      nvim-web-devicons
      smart-splits-nvim
      snacks-nvim
      treesitter-modules-nvim
    ];
  };

  config.specs.colorscheme = {
    data = with pkgs.vimPlugins; [
      kanagawa-nvim
    ];
    lazy = true;
  };

  config.specMods =
    {
      # When this module is ran in an inner list,
      # this will contain `config` of the parent spec
      parentSpec ? null,
      # and this will contain `options`
      # otherwise they will be `null`
      parentOpts ? null,
      parentName ? null,
      # and then config from this one, as normal
      config,
      # and the other module arguments.
      ...
    }:
    {
      # you could use this to change defaults for the specs
      # config.collateGrammars = lib.mkDefault (parentSpec.collateGrammars or false);
      # config.autoconfig = lib.mkDefault (parentSpec.autoconfig or false);
      # config.runtimeDeps = lib.mkDefault (parentSpec.runtimeDeps or false);
      # config.pluginDeps = lib.mkDefault (parentSpec.pluginDeps or false);
      # or something more interesting like:
      # add an extraPackages field to the specs themselves
      options.extraPackages = lib.mkOption {
        type = lib.types.listOf wlib.types.stringable;
        default = [ ];
        description = "a extraPackages spec field to put packages to suffix to the PATH";
      };
      # You could do this too
      # config.before = lib.mkDefault [ "INIT_MAIN" ];
    };
  config.extraPackages = config.specCollect (acc: v: acc ++ (v.extraPackages or [ ])) [ ];

  # Inform our lua of which top level specs are enabled
  options.settings.cats = lib.mkOption {
    readOnly = true;
    type = lib.types.attrsOf lib.types.bool;
    default = builtins.mapAttrs (_: v: v.enable) config.specs;
  };

  # build plugins from inputs set
  options.nvim-lib.pluginsFromPrefix = lib.mkOption {
    type = lib.types.raw;
    readOnly = true;
    default =
      prefix: inputs:
      lib.pipe inputs [
        builtins.attrNames
        (builtins.filter (s: lib.hasPrefix prefix s))
        (map (
          input:
          let
            name = lib.removePrefix prefix input;
          in
          {
            inherit name;
            value = config.nvim-lib.mkPlugin name inputs.${input};
          }
        ))
        builtins.listToAttrs
      ];
  };
}
