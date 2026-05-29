{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  # Base User Packages (CLI Tools)
  home.packages = with pkgs; [
    direnv
    zoxide
    aria2
    taskwarrior3
    yt-dlp
    megasync
    nchat
    lazygit
    spotify-player
    termscp
  ];

  # Core User Programs
  programs = {
    # Shell prompt customization
    starship = {
      enable = true;
      settings = {
        time.disabled = false;
        time.use_12hr = true;
        time.style = ''#cfae71'';
      };
    };

    # SSH client configuration
    ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings."*" = {
        forwardAgent = false;
        addKeysToAgent = "no";
        compression = false;
        serverAliveInterval = 0;
        serverAliveCountMax = 3;
        hashKnownHosts = false;
        userKnownHostsFile = "~/.ssh/known_hosts";
        controlMaster = "no";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "no";
      };
    };

    home-manager.enable = true;
  };

  # User-level Services
  services = {
    lorri.enable = true; # Nix shell daemon for direnv
    ssh-agent.enable = true;
  };
}
