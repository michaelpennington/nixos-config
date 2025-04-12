# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  pkgs,
  inputs,
  ...
}:
# let
# packwiz = pkgs.buildGoModule {
#   name = "packwiz";
#   src = inputs.packwiz;
#   vendorHash = "sha256-krdrLQHM///dtdlfEhvSUDV2QljvxFc2ouMVQVhN7A0=";
# };
# in
{
  imports = [
    ./hardware-configuration.nix
    inputs.nixvim.nixosModules.nixvim
    inputs.ucodenix.nixosModules.default
    # inputs.nix-minecraft.nixosModules.minecraft-servers
  ];

  # nixpkgs.overlays = [inputs.nix-minecraft.overlay];

  nixpkgs.config.allowUnfree = true;

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelParams = ["microcode.amd_sha_check=off"];
  };
  time.hardwareClockInLocalTime = true;

  hardware.graphics.enable = true;

  networking.hostName = "poseidon";
  networking.networkmanager.enable = true;

  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; # use xkb.options in tty.
  };

  services = {
    printing = {
      enable = true;
      allowFrom = ["all"];
      browsing = true;
      defaultShared = true;
      openFirewall = true;
    };
    pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
    };
    ucodenix = {
      enable = true;
      cpuModelId = "00A20F12";
    };
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    openssh.enable = true;
    gnome.gnome-keyring.enable = true;
    # minecraft-servers = {
    #   enable = true;
    #   eula = true;
    #
    #   servers = {
    #     solo_world = let
    #       modpack = pkgs.fetchPackwizModpack {
    #         url = "https://github.com/michaelpennington/server_mods/raw/refs/heads/main/pack.toml";
    #         packHash = "sha256-q+rBevqkmqzVwmOeWukPrplNg64aK62uuSaYuRXZjtg=";
    #       };
    #       mcVersion = modpack.manifest.versions.minecraft;
    #       fabricVersion = modpack.manifest.versions.fabric;
    #       serverVersion = lib.replaceStrings ["."] ["_"] "fabric-${mcVersion}";
    #     in {
    #       enable = true;
    #       package = pkgs.fabricServers.${serverVersion}.override {loaderVersion = fabricVersion;};
    #       autoStart = false;
    #       symlinks = {
    #         "mods" = "${modpack}/mods";
    #       };
    #       serverProperties = {
    #         level-name = "Survival World";
    #         difficulty = "hard";
    #       };
    #       files = {
    #         "config" = "${modpack}/config";
    #       };
    #       jvmOpts = "-XX:+UnlockExperimentalVMOptions -XX:+UnlockDiagnosticVMOptions -XX:+AlwaysActAsServerClassMachine -XX:+AlwaysPreTouch -XX:+DisableExplicitGC -XX:+UseNUMA -XX:NmethodSweepActivity=1 -XX:ReservedCodeCacheSize=400M -XX:NonNMethodCodeHeapSize=12M -XX:ProfiledCodeHeapSize=194M -XX:NonProfiledCodeHeapSize=194M -XX:-DontCompileHugeMethods -XX:MaxNodeLimit=240000 -XX:NodeLimitFudgeFactor=8000 -XX:+UseVectorCmov -XX:+PerfDisableSharedMem -XX:+UseFastUnorderedTimeStamps -XX:+UseCriticalJavaThreadPriority -XX:ThreadPriorityPolicy=1 -XX:+UseZGC -XX:AllocatePrefetchStyle=1 -XX:-ZProactive -Xms8G -Xmx8G -XX:+UseTransparentHugePages -XX:ConcGCThreads=10";
    #     };
    #   };
    # };
  };

  users.users.mpennington = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager"]; # Enable ‘sudo’ for the user.
  };

  nix.settings = {
    trusted-users = ["root" "mpennington"];
    experimental-features = ["nix-command" "flakes"];
  };

  environment.systemPackages = with pkgs; [
    inputs.alejandra.defaultPackage.${system}
    inputs.nixd.packages.${system}.default
    bat
    unzip
    bottom
    eza
    fd
    gcc
    gh
    packwiz
    ripgrep
    rustup
    gnumake
    stow
    vscode-extensions.vadimcn.vscode-lldb
    w3m
    wget
    xdg-user-dirs
  ];

  fonts.packages = with pkgs; [
    fantasque-sans-mono
    fira-code
    fira-code-symbols
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    nerd-fonts.fantasque-sans-mono
    nerd-fonts.fira-code
  ];

  programs = {
    fish.enable = true;
    git.enable = true;
    nixvim = {
      enable = true;
      defaultEditor = true;
      extraPlugins = [pkgs.vimPlugins.phha-zenburn];
      colorscheme = "zenburn";
      opts = {
        autoindent = true;
        expandtab = true;
        tabstop = 2;
        softtabstop = 2;
        shiftwidth = 2;
        number = true;
        relativenumber = true;
        mouse = "";
        foldlevel = 20;
        foldcolumn = "1";
        foldmethod = "expr";
        foldexpr = "nvim_treesitter#foldexpr()";
        undofile = true;
      };
      globals.mapleader = " ";
      plugins = {
        gitsigns.enable = true;
        lazygit.enable = true;
        smart-splits = {
          enable = true;
          settings = {
          };
        };
        barbar = {
          enable = true;
          keymaps = {
            close.key = "<leader>c";
            next.key = "L";
            previous.key = "H";
            moveNext.key = "<A-L>";
            movePrevious.key = "<A-H>";
          };
        };
        neo-tree.enable = true;
        treesitter = {
          enable = true;
          settings = {
            highlight.enable = true;
          };
        };
        conform-nvim = {
          enable = true;
          settings = {
            formatters_by_ft = {
              nix = [
                "alejandra"
              ];
              c = ["clang_format"];
              cpp = ["clang_format"];
            };
            format_on_save = {
              lsp_format = "fallback";
              timeout_ms = 500;
            };
          };
        };
        web-devicons.enable = true;
        transparent.enable = true;
        rustaceanvim.enable = true;
        lsp = {
          enable = true;
          keymaps = {
            diagnostic = {
              "<leader>j" = "goto_next";
              "<leader>k" = "goto_prev";
            };
            lspBuf = {
              K = "hover";
              gD = "references";
              gd = "definition";
              gi = "implementation";
              gt = "type_definition";
            };
          };
          servers = {
            nixd = {
              enable = true;
              package = inputs.nixd.packages.${pkgs.system}.default;
            };
            clangd.enable = true;
          };
        };
        cmp = {
          enable = true;
          settings = {
            mapping = {
              "<C-Space>" = "cmp.mapping.complete()";
              "<C-d>" = "cmp.mapping.scroll_docs(-4)";
              "<C-e>" = "cmp.mapping.close()";
              "<C-f>" = "cmp.mapping.scroll_docs(4)";
              "<CR>" = "cmp.mapping.confirm({ select = true })";
              "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
              "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
            };
            sources = [
              {name = "nvim_lsp";}
              {name = "path";}
              {name = "buffer";}
            ];
          };
        };
        dap.enable = true;
        dap-lldb = {
          enable = true;
          settings.codelldb_path = "${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb";
        };
        dap-ui.enable = true;
        dap-virtual-text.enable = true;
        mini = {
          enable = true;
          modules = {
            comment = {
              mappings = {
                comment = "<leader>/";
                comment_line = "<leader>/";
                comment_visual = "<leader>/";
                textobject = "<leader>/";
              };
            };
            starter = {
              content_hooks = {
                "__unkeyed-1.adding_bullet" = {
                  __raw = "require('mini.starter').gen_hook.adding_bullet()";
                };
                "__unkeyed-2.indexing" = {
                  __raw = "require('mini.starter').gen_hook.indexing('all', { 'Builtin actions' })";
                };
                "__unkeyed-3.padding" = {
                  __raw = "require('mini.starter').gen_hook.aligning('center', 'center')";
                };
              };
              evaluate_single = true;
              header = ''
                ███╗   ██╗██╗██╗  ██╗██╗   ██╗██╗███╗   ███╗
                ████╗  ██║██║╚██╗██╔╝██║   ██║██║████╗ ████║
                ██╔██╗ ██║██║ ╚███╔╝ ██║   ██║██║██╔████╔██║
                ██║╚██╗██║██║ ██╔██╗ ╚██╗ ██╔╝██║██║╚██╔╝██║
                ██║ ╚████║██║██╔╝ ██╗ ╚████╔╝ ██║██║ ╚═╝ ██║
              '';
              items = {
                "__unkeyed-1.buildtin_actions" = {
                  __raw = "require('mini.starter').sections.builtin_actions()";
                };
                "__unkeyed-2.recent_files_current_directory" = {
                  __raw = "require('mini.starter').sections.recent_files(10, false)";
                };
                "__unkeyed-3.recent_files" = {
                  __raw = "require('mini.starter').sections.recent_files(10, true)";
                };
                "__unkeyed-4.sessions" = {
                  __raw = "require('mini.starter').sections.sessions(5, true)";
                };
              };
            };
            ai = {
              n_lines = 50;
              search_method = "cover_or_next";
            };
            pairs = {};
          };
        };
        lualine = {
          enable = true;
          settings.options.theme = "zenburn";
        };
      };
      keymaps = [
        {
          action =
            config.lib.nixvim.mkRaw
            # Lua
            ''vim.lsp.buf.rename'';
          key = "grn";
          mode = ["n" "v"];
          options = {
            silent = true;
            desc = "Rename object";
          };
        }
        {
          action = ":Neotree filesystem toggle<CR>";
          key = "<leader>e";
          mode = "n";
          options = {
            silent = true;
            desc = "Toggle neotree";
          };
        }
        {
          action =
            config.lib.nixvim.mkRaw
            # Lua
            ''vim.lsp.buf.code_action'';
          key = "<leader>ca";
          mode = ["n" "v"];
          options = {
            silent = true;
            desc = "Code action";
          };
        }
        {
          action =
            config.lib.nixvim.mkRaw
            # Lua
            ''require('smart-splits').resize_left'';
          key = "<A-h>";
          mode = ["n"];
          options = {
            silent = true;
            desc = "Resize split left";
          };
        }
        {
          action =
            config.lib.nixvim.mkRaw
            # Lua
            ''require('smart-splits').resize_right'';
          key = "<A-l>";
          mode = ["n"];
          options = {
            silent = true;
            desc = "Resize split right";
          };
        }
        {
          action =
            config.lib.nixvim.mkRaw
            # Lua
            ''require('smart-splits').resize_up'';
          key = "<A-k>";
          mode = ["n"];
          options = {
            silent = true;
            desc = "Resize split up";
          };
        }
        {
          action =
            config.lib.nixvim.mkRaw
            # Lua
            ''require('smart-splits').resize_down'';
          key = "<A-j>";
          mode = ["n"];
          options = {
            silent = true;
            desc = "Resize split down";
          };
        }
        {
          action =
            config.lib.nixvim.mkRaw
            # Lua
            ''require('smart-splits').move_cursor_left'';
          key = "<C-h>";
          mode = ["n"];
          options = {
            silent = true;
            desc = "Move to window to the left";
          };
        }
        {
          action =
            config.lib.nixvim.mkRaw
            # Lua
            ''require('smart-splits').move_cursor_down'';
          key = "<C-j>";
          mode = ["n"];
          options = {
            silent = true;
            desc = "Move to window below";
          };
        }
        {
          action =
            config.lib.nixvim.mkRaw
            # Lua
            ''require('smart-splits').move_cursor_up'';
          key = "<C-k>";
          mode = ["n"];
          options = {
            silent = true;
            desc = "Move to window above";
          };
        }
        {
          action =
            config.lib.nixvim.mkRaw
            # Lua
            ''require('smart-splits').move_cursor_right'';
          key = "<C-l>";
          mode = ["n"];
          options = {
            silent = true;
            desc = "Move to window to the right";
          };
        }
        {
          action =
            config.lib.nixvim.mkRaw
            # Lua
            ''require('smart-splits').swap_buf_left'';
          key = "<leader><leader>h";
          mode = ["n"];
          options = {
            silent = true;
            desc = "Swap with window to the left";
          };
        }
        {
          action =
            config.lib.nixvim.mkRaw
            # Lua
            ''require('smart-splits').swap_buf_down'';
          key = "<leader><leader>j";
          mode = ["n"];
          options = {
            silent = true;
            desc = "Swap with window below";
          };
        }
        {
          action =
            config.lib.nixvim.mkRaw
            # Lua
            ''require('smart-splits').swap_buf_up'';
          key = "<leader><leader>k";
          mode = ["n"];
          options = {
            silent = true;
            desc = "Swap with window above";
          };
        }
        {
          action =
            config.lib.nixvim.mkRaw
            # Lua
            ''require('smart-splits').swap_buf_right'';
          key = "<leader><leader>l";
          mode = ["n"];
          options = {
            silent = true;
            desc = "Swap with window to the right";
          };
        }
        {
          mode = "n";
          key = "<leader>db";
          action = "<cmd>lua require'dap'.toggle_breakpoint()<cr>";
          options = {
            desc = "DAP Toggle Breakpoint";
            silent = true;
          };
        }
        {
          mode = "n";
          key = "<leader>dBc";
          action = "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<cr>";
          options = {
            desc = "DAP Set Conditional Breakpoint";
            silent = true;
          };
        }
        {
          mode = "n";
          key = "<leader>dBl";
          action = "<cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<cr>";
          options = {
            desc = "DAP Set Log Breakpoint";
            silent = true;
          };
        }
        {
          mode = "n";
          key = "<leader>dc";
          action = "<cmd>lua require'dap'.continue()<cr>";
          options = {
            desc = "DAP Continue";
            silent = true;
          };
        }
        {
          mode = "n";
          key = "<leader>dsi";
          action = "<cmd>lua require'dap'.step_into()<cr>";
          options = {
            desc = "DAP Step Into";
            silent = true;
          };
        }
        {
          mode = "n";
          key = "<leader>dso";
          action = "<cmd>lua require'dap'.step_over()<cr>";
          options = {
            desc = "DAP Step Over";
            silent = true;
          };
        }
        {
          mode = "n";
          key = "<leader>dsO";
          action = "<cmd>lua require'dap'.step_out()<cr>";
          options = {
            desc = "DAP Step Out";
            silent = true;
          };
        }
        {
          mode = "n";
          key = "<leader>dt";
          action = "<cmd>lua require'dap'.terminate()<cr>";
          options = {
            desc = "DAP Terminate";
            silent = true;
          };
        }
        {
          mode = "n";
          key = "<leader>dr";
          action = "<cmd>lua require'dap'.repl.open()<cr>";
          options = {
            desc = "Open REPL";
            silent = true;
          };
        }
        {
          mode = "n";
          key = "<leader>dl";
          action = "<cmd>lua require'dap'.run_last()<cr>";
          options = {
            desc = "Run Last";
            silent = true;
          };
        }
        {
          mode = "n";
          key = "<leader>du";
          action = "<cmd>lua require'dapui'.toggle()<cr>";
          options = {
            desc = "Dap UI Toggle";
            silent = true;
          };
        }
      ];
      userCommands = {
        "Format" = {
          range = true;
          desc = "Format the current buffer";
          command =
            config.lib.nixvim.mkRaw
            # Lua
            ''
              function(args)
                local range = nil
                if args.count ~= -1 then
                  local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
                  range = {
                    start = { args.line1, 0 },
                    ["end"] = { args.line2, end_line:len() },
                  }
                end
                require("conform").format({ async = true, lsp_format = "fallback", range = range })
              end
            '';
        };
        "FormatDisable" = {
          bang = true;
          desc = "Disable autoformat on save";
          command =
            config.lib.nixvim.mkRaw
            # Lua
            ''
              function(args)
                if args.bang then
                  vim.b.disable_autoformat = true
                else
                  vim.g.disable_autoformat = true
                end
              end
            '';
        };
        "FormatEnable" = {
          desc = "Re-enable autoformat on save";
          command =
            config.lib.nixvim.mkRaw
            # Lua
            ''
              function()
                vim.b.disable_autoformat = false
                vim.g.disable_autoformat = false
              end
            '';
        };
      };
    };
    tmux.enable = true;
  };

  xdg.portal = {
    enable = true;

    config = {
      common = {
        default = [
          "gtk"
        ];
        "org.freedesktop.impl.portal.Secret" = [
          "gnome-keyring"
        ];
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
        ];
      };
    };
  };

  security.polkit.enable = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?
}
