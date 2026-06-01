{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  # Base User Packages (CLI Tools)
  home.packages = with pkgs; [
    aria2
    taskwarrior3
    yt-dlp
    megasync
    nchat
    lazygit
    spotify-player
    inputs.nixpkgs-stable.legacyPackages."x86_64-linux".termscp
  ];

  # Core User Programs
  programs = {
    # Syntax highlighting
    bat = {
      enable = true;
      config.theme = "gruvbox-flat";
      themes.gruvbox-flat = {
        src = ./configs/bat;
        file = "gruvbox-flat.tmTheme";
      };
    };

    # Terminal multiplexer
    tmux = {
      enable = true;
      extraConfig = ''
        set -g default-shell /usr/bin/fish
      '';
    };

    # Fish shell
    fish = {
      enable = true;

      shellAbbrs = {
        ll = "eza --icons -lah";
        llll = "eza --icons -lagh@T --git";
        lll = "eza --icons -lagh@ --git";
        l = "eza --icons --";
        cp = "cp -rv";
        mv = "mv -v";
        mkdir = "mkdir -vp";
      };

      functions = {
        fish_greeting = {
          body = ''
            echo Good (print_tod), (set_color magenta)$USER(set_color normal)! Welcome to (set_color red)$hostname(set_color normal).\n
            echo -ns \t"The date is " (set_color yellow; date +"%A"; set_color normal) ", "
            echo -ns (set_color green; date +"%B %e"; set_color normal) ", "
            echo -s (set_color blue; date +"%Y"; set_color normal) "."
            echo -s \t"The time is " (set_color cyan; date +"%r"; set_color normal) "."
          '';
        };
        print_tod = {
          body = ''
            set -l hour (date "+%H")
            if test \( $hour -gt 3 \) -a \( $hour -lt 12 \)
              echo morning
            else if test \( $hour -ge 12 \) -a \( $hour -lt 18 \)
              echo afternoon
            else
              echo evening
            end
          '';
        };
        sudo = {
          body = ''
            set -l fish_path (command -v fish)
            env SHELL=$(command -v fish) $(command -v sudo) -sE $argv
          '';
        };
        switch_audio = {
          body = ''
            set -l options (fish_opt -s t -l toggle)
            set -al options (fish_opt -s b -l bluetooth)
            set -al options (fish_opt -s p -l headphones)
            set -al options (fish_opt -s s -l speakers)
            set -al options (fish_opt -s h -l help)
            argparse -x toggle,bluetooth,headphones,speakers
          '';
        };
      };

      interactiveShellInit = ''
        # VI Keybindings
        fish_vi_key_bindings
        set fish_cursor_default block
        set fish_cursor_insert line
        set fish_cursor_replace_one underscore
        set fish_cursor_visual block
        set -gx fish_vi_force_cursor
        fish_vi_cursor

        # Legacy frozen theme colors
        set -g fish_color_autosuggestion 555 brblack
        set -g fish_color_cancel -r
        set -g fish_color_command 005fd7
        set -g fish_color_comment 990000
        set -g fish_color_cwd green
        set -g fish_color_cwd_root red
        set -g fish_color_end 009900
        set -g fish_color_error ff0000
        set -g fish_color_escape 00a6b2
        set -g fish_color_history_current --bold
        set -g fish_color_host normal
        set -g fish_color_host_remote yellow
        set -g fish_color_normal normal
        set -g fish_color_operator 00a6b2
        set -g fish_color_param 00afff
        set -g fish_color_quote 999900
        set -g fish_color_redirection 00afff
        set -g fish_color_search_match white --background=brblack
        set -g fish_color_selection white --bold --background=brblack
        set -g fish_color_status red
        set -g fish_color_user brgreen
        set -g fish_color_valid_path --underline
        set -g fish_pager_color_completion
        set -g fish_pager_color_description B3A06D yellow
        set -g fish_pager_color_prefix normal --bold --underline
        set -g fish_pager_color_progress brwhite --background=cyan
        set -g fish_pager_color_selected_background -r
      '';

      plugins = [
        {
          name = "bass";
          src = pkgs.fishPlugins.bass.src;
        }
        {
          name = "abbreviation-tips";
          src = pkgs.fetchFromGitHub {
            owner = "gazorby";
            repo = "fish-abbreviation-tips";
            rev = "v0.7.0";
            sha256 = "sha256-F1t81VliD+v6WEWqj1c1ehFBXzqLyumx5vV46s/FZRU=";
          };
        }
      ];
    };

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
      settings."*" = {AddKeysToAgent = "yes";};
      includes = ["/run/agenix/hermes-ssh"];
    };

    home-manager.enable = true;

    # Smart directory jumping
    zoxide.enable = true;

    # Environment management
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };

  # Session Environment Variables
  home.sessionVariables = {
    BROWSER = "firefox";
    EDITOR = "nvim";
    VISUAL = "nvim";
    DIFFPROG = "nvim -d";
    CHROOT = "${config.home.homeDirectory}/chroot";
    ASYMPTOTE_PSVIEWER = "zathura";
    ASYMPTOTE_PDFVIEWER = "zathura";
  };

  # Font Configuration
  fonts.fontconfig.enable = true;
  xdg.configFile."fontconfig/conf.d/10-fantasque-sans-mono.conf".text = ''
    <match target='font'>
        <test name='fontformat' compare='not_eq'>
            <string/>
        </test>
        <test name='family'>
            <string>Fantasque Sans Mono</string>
        </test>
        <edit name='fontfeatures' mode='assign_replace'>
            <string>ss01</string>
        </edit>
    </match>
  '';

  # Fish Assets
  xdg.configFile."fish/completions/packwiz.fish".source = ./configs/fish/completions/packwiz.fish;
  xdg.configFile."fish/themes/kanagawa.theme".source = ./configs/fish/themes/kanagawa.theme;

  # User-level Services
  services = {
    lorri.enable = true; # Nix shell daemon for direnv
    ssh-agent.enable = true;
  };
}
