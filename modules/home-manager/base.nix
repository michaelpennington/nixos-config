{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
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
    # add other base CLI tools here
  ];

  programs = {
    starship = {
      enable = true;
      settings = {
        time.disabled = false;
        time.use_12hr = true;
        time.style = ''#cfae71'';
      };
    };
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

  services.lorri.enable = true;
  services.ssh-agent.enable = true;
}
