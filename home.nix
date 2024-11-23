{ config, pkgs, inputs, ... }:
{
  home.username = "mpennington";
  home.homeDirectory = "/home/mpennington";

  home.stateVersion = "24.05";

  home.packages = with pkgs; [
    inputs.prismlauncher.packages."${pkgs.system}".prismlauncher
    inputs.wezterm.packages."${pkgs.system}".default
  ];

  programs.starship = {
    enable = true;
    settings = {
      time.disabled = false;
      time.use_12hr = true;
      time.style = ''#cfae71'';
    };
  };

  wayland.windowManager.sway = {
    enable = true;
    extraConfig = builtins.readFile ./sway_config;
    config.bars = [];
  };

  programs.home-manager.enable = true;
}
