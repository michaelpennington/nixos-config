{ config, pkgs, inputs, ... }:
{
  home.username = "mpennington";
  home.homeDirectory = "/home/mpennington";

  home.stateVersion = "24.05";

  home.packages = with pkgs; [
    inputs.prismlauncher.packages."${pkgs.system}".prismlauncher
  ];

  programs.starship = {
    enable = true;
    settings = {
      time.disabled = false;
      time.use_12hr = true;
      time.style = ''#cfae71'';
    };
  };

  programs.home-manager.enable = true;
}
