inputs:
{
  config,
  wlib,
  lib,
  pkgs,
  ...
}:
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

  config.settings.config_directory = "/home/mpennington/nixos-config/neovim/config";

  config.specs.lze = [
    config.nvim-lib.neovimPlugins.lze
    {
      data = config.nvim-lib.neovimPlugins.lzextras;
      name = "lzextras";
    }
  ];
  config.specs.general = {
    data = with pkgs.vimPlugins; [
      nvim-treesitter
      treesitter-modules-nvim
      nvim-treesitter-textobjects
      nvim-lspconfig
      nvim-treesitter.withAllGrammars
    ];
  };
  
  config.specs.colorscheme = {
    data = with pkgs.vimPlugins; [
      kanagawa-nvim
    ];
    lazy = true;
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
