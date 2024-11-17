{ config, pkgs, ... }:
{
  home.username = "mpennington";
  home.homeDirectory = "/home/mpennington";

  home.stateVersion = "24.05";

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
