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
    termscp
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
        clone = {
          description = "cd $BUILD_BASE && git clone $FREECAD_REPO && cd FreeCAD && git submodule update --init --recursive";
          body = "cd $BUILD_BASE && git clone $FREECAD_REPO && cd FreeCAD && git submodule update --init --recursive $argv";
        };
        compile = {
          description = "cmake --build $BUILD_BASE/build";
          body = "cmake --build $BUILD_BASE/build $argv";
        };
        config_freecad = {
          # Renamed from 'config' to avoid collision with builtin fish config command
          description = "mkdir -p $BUILD_BASE/build && cd $BUILD_BASE/build && cmake -GNinja -DFREECAD_USE_PYBIND11=ON -DCMAKE_INSTALL_PREFIX=/usr/local $BUILD_BASE/FreeCAD";
          body = "mkdir -p $BUILD_BASE/build && cd $BUILD_BASE/build && cmake -GNinja -DFREECAD_USE_PYBIND11=ON -DCMAKE_INSTALL_PREFIX=/usr/local $BUILD_BASE/FreeCAD $argv";
        };
        pull = {
          description = "cd $BUILD_BASE/FreeCAD && git pull && git submodule update --init --recursive";
          body = "cd $BUILD_BASE/FreeCAD && git pull && git submodule update --init --recursive $argv";
        };
        freecad = {
          description = "Run FreeCAD from build directory";
          body = "$BUILD_BASE/build/bin/FreeCAD -P $PYLIB0/lib -P $PYLIB0/lib/python3.12/site-packages $argv";
        };
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
        cluse = {
          body = ''
            set -gx CC /usr/bin/clang
            set -gx CXX /usr/bin/clang++
            set -gx LD /usr/bin/ld.lld
            set -gx CC_LD /usr/bin/ld.lld
            set -gx CXX_LD /usr/bin/ld.lld
          '';
        };
        export-esp = {
          body = ''
            set -gx LIBCLANG_PATH "${config.home.homeDirectory}/.espressif/tools/xtensa-esp32-elf-clang/esp-15.0.0-20221201-x86_64-unknown-linux-gnu/esp-clang/lib"
            set -e CC
            set -e CXX
            set -e CC_LD
            set -e LD
            set -e CXX_LD
            fish_add_path -P ${config.home.homeDirectory}/.espressif/tools/riscv32-esp-elf/esp-2021r2-patch5-8_4_0/riscv32-esp-elf/bin
            fish_add_path -P ${config.home.homeDirectory}/.espressif/tools/xtensa-esp32s2-elf/esp-2021r2-patch5-8_4_0/xtensa-esp32s2-elf/bin
            fish_add_path -P ${config.home.homeDirectory}/.espressif/tools/xtensa-esp32s3-elf/esp-2021r2-patch5-8_4_0/xtensa-esp32s3-elf/bin
            fish_add_path -P ${config.home.homeDirectory}/.espressif/tools/xtensa-esp32-elf/esp-2021r2-patch5-8_4_0/xtensa-esp32-elf/bin
          '';
        };
        getpks = {
          body = ''
            set -l pks (cat $argv[1] | string split -n '\n' | string match -v -r '#.*')
            set -l sys_pks (cat /var/lib/portage/world | string split -n '\n')

            for pk in $pks
              if not contains $pk $sys_pks
                echo $pk
              end
            end
          '';
        };
        gupd = {
          body = ''
            set -l timefile "${config.home.homeDirectory}/.cache/gupd/last-update"

            read -p 'gcolor y "Update repositories?" w " [" g "a" w "/" m "g" w "/" r "N" w "] "' var
            switch $var
              case 'a' 'A' 'y' 'Y'
                set -l now (date '+%s')
                if test -e "$timefile"
                  set old_time (cat "$timefile")
                  if test (math "$old_time + 86400") -gt $now
                    set remaining (math "$old_time + 86400 - $now")
                    remaining $remaining | read -l amt unit
                    gcolor -n r "[Error] " "E81" "Please wait " "FFF" "$amt" "E81" " $unit to sync gentoo repo."
                    return 1
                  end
                end
                gcolor -n g "Will update all repos"
                command sudo emaint sync -A || return 1
                echo "$now" > "$timefile"
              case 'g' 'G'
                set repos (
                  cat "/etc/portage/repos.conf/eselect-repo.conf" \
                    | string match -ae '[' \
                    | string sub -s '2' -e '-1' \
                    | string match -v '*local*'
                )
                for repo in $repos
                  command sudo emaint sync -r $repo || return 1
                end
            end
            command sudo emerge -avuDN @world
          '';
        };
        remaining = {
          body = ''
            set -l sec $argv[1]
            if test $sec -eq 1
              echo "1 second"
            else if test $sec -lt 60
              echo "$sec seconds"
            else if test $sec -lt 120
              echo "1 minute"
            else if test $sec -lt 3600
              set mins (math -s0 "$sec / 60")
              echo "$mins minutes"
            else if test $sec -lt 7200
              echo "1 hour"
            else
              set hrs (math -s0 "$sec / 3600")
              echo "$hrs hours"
            end
          '';
        };
        gcolor = {
          body = ''
            set -l fst $argv[1]
            if test "$fst" = "-n"
              set ind 2
            else
              set ind 1
            end

            set -l len (count $argv)
            while test $ind -le $len
            set_color normal
              switch $argv[$ind]
                case 'd'
                  set_color black
                case 'r'
                  set_color red
                case 'g'
                  set_color green
                case 'y'
                  set_color yellow
                case 'b'
                  set_color blue
                case 'm'
                  set_color magenta
                case 'c'
                  set_color cyan
                case 'w'
                  set_color white
              end
              if string match -q -r '^[0-9a-fA-F]{3}(?:[0-9a-fA-F]{3})?$' $argv[$ind]
                set_color $argv[$ind]
              end
              echo -n $argv[(math $ind + 1)]
              set_color normal
              set ind (math $ind + 2)
            end
            
            if test "$fst" = "-n"
              echo ""
            end
          '';
        };
        sudo = {
          body = ''
            set -l fish_path (command -v fish)
            env SHELL=$fish_path command sudo -sE $argv
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
