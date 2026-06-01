inputs: {
  config,
  wlib,
  lib,
  pkgs,
  ...
}: let
  # Build cargo.nvim from source using Nix's Rust platform
  cargo-nvim = (
    pkgs.rustPlatform.buildRustPackage {
      pname = "cargo.nvim";
      version = "2b470e7";
      src = inputs.cargo-nvim;
      cargoHash = "sha256-eBSmhaU/ycci2lmGIwwocJGLkmBjfMXQyh18AEqDjx4=";
      doCheck = false;
      nativeBuildInputs = [pkgs.pkg-config];
      buildInputs = [pkgs.luajit];

      installPhase = ''
        mkdir -p $out/target/release
        mkdir -p $out/lua
        cp target/*/release/libcargo_nvim.so $out/target/release/
        cp -r lua/* $out/lua/
        cp -r plugin $out/ || true
        cp -r doc $out/ || true
      '';
    }
  );
in {
  # Import the Neovim wrapper module from nix-wrapper-modules
  imports = [wlib.wrapperModules.neovim];

  # Neovim Plugin Management Options
  options.nvim-lib.neovimPlugins = lib.mkOption {
    readOnly = true;
    type = lib.types.attrsOf wlib.types.stringable;
    # Automatically convert flake inputs prefixed with 'plugins-' into Neovim plugins
    default = config.nvim-lib.pluginsFromPrefix "plugins-" inputs;
  };

  # Main configuration directory for Lua files
  config.settings.config_directory = ../nvim;

  # Integration with Home Manager
  config.install.optionLocation = ["wrappers" "neovim"];

  # Plugin Specification (Specs) - Grouped by language/functionality
  config.specs.lze = [
    config.nvim-lib.neovimPlugins.lze
    {
      data = config.nvim-lib.neovimPlugins.lzextras;
      name = "lzextras";
    }
  ];

  # Agda support
  config.specs.agda = {
    after = ["general"];
    data = with pkgs.vimPlugins; [
      cornelis
    ];
    runtimePkgs = let
    in [
      (inputs.nixpkgs-stable.legacyPackages."x86_64-linux".agda.withPackages
        (p: [p.standard-library]))
    ];
  };

  # Nix development
  config.specs.nix = {
    data = null;
    runtimePkgs = with pkgs; [
      alejandra
      nixd
    ];
  };

  # Rust development
  config.specs.rust = {
    after = ["general"];
    lazy = true;
    data = with pkgs.vimPlugins; [
      rustaceanvim
      crates-nvim
      cargo-nvim
    ];
    runtimePkgs = with pkgs; [
      rust-analyzer
    ];
  };

  # Lua development
  config.specs.lua = {
    after = ["general"];
    lazy = true;
    data = with pkgs.vimPlugins; [
      lazydev-nvim
    ];
    runtimePkgs = with pkgs; [
      lua-language-server
      stylua
    ];
  };

  # C/C++ development
  config.specs.cCpp = {
    after = ["general"];
    lazy = true;
    runtimePkgs = with pkgs; [
      clang-tools
    ];
    data = with pkgs.vimPlugins; [
      clangd_extensions-nvim
    ];
  };

  # General editor functionality and UI
  config.specs.general = {
    after = ["lze"];
    lazy = true;

    runtimePkgs = with pkgs; [
      lazygit
      tree-sitter
      codespell
    ];

    data = with pkgs.vimPlugins; [
      barbar-nvim
      blink-cmp
      blink-compat
      cmp-cmdline
      colorful-menu-nvim
      conform-nvim
      fidget-nvim
      friendly-snippets
      gitsigns-nvim
      lualine-nvim
      mini-ai
      mini-clue
      mini-comment
      mini-extra
      mini-hipatterns
      mini-icons
      mini-pairs
      neorg
      nvim-lint
      nvim-lspconfig
      nvim-navic
      nvim-surround
      nvim-treesitter
      nvim-treesitter-textobjects
      nvim-treesitter.withAllGrammars
      (nvim-treesitter.withPlugins
        (_: [pkgs.tree-sitter-grammars.tree-sitter-fstar]))
      nvim-web-devicons
      oil-git-status-nvim
      oil-lsp-diagnostics-nvim
      oil-nvim
      otter-nvim
      smart-splits-nvim
      snacks-nvim
      treesitter-modules-nvim
      vim-startuptime
    ];
  };

  # Colorscheme specification
  config.specs.colorscheme = {
    data = [
      {
        data = config.nvim-lib.neovimPlugins.kanagawa-paper-nvim;
        name = "kanagawa-paper.nvim";
      }
    ];
    lazy = true;
  };

  # Internal Logic: Collect and expose runtime packages
  config.specMods = {
    config,
    ...
  }: {
    options.runtimePkgs = lib.mkOption {
      type = lib.types.listOf wlib.types.stringable;
      default = [];
      description = "a runtimePkgs spec field to put packages to suffix to the PATH";
    };
  };
  config.runtimePkgs = config.specCollect (acc: v: acc ++ (v.runtimePkgs or [])) [];

  # Inform our lua of which top level specs are enabled
  options.settings.cats = lib.mkOption {
    readOnly = true;
    type = lib.types.attrsOf lib.types.bool;
    default = builtins.mapAttrs (_: v: v.enable) config.specs;
  };

  # Helper function to build plugins from inputs
  options.nvim-lib.pluginsFromPrefix = lib.mkOption {
    type = lib.types.raw;
    readOnly = true;
    default = prefix: inputs:
      lib.pipe inputs [
        builtins.attrNames
        (builtins.filter (s: lib.hasPrefix prefix s))
        (map (
          input: let
            name = lib.removePrefix prefix input;
          in {
            inherit name;
            value = config.nvim-lib.mkPlugin name inputs.${input};
          }
        ))
        builtins.listToAttrs
      ];
  };
}
