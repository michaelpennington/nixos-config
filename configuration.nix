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
  # boot.loader.grub.configurationLimit = 10;

  # Perform garbage collection weekly to maintain low disk usage

  boot = {
    loader.systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };
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
    udev = {
      enable = true;
      extraRules = ''
              ## Rules file for NetMD devices and HiMD devices in NetMD mode
        ## source: https://usb-ids.gowdy.us/read/UD/054c
        ## last changed: 2025-05-05
        ## updated to 'uaccess' by SammysHP
        ## updated to support HiMD devices in mass storage mode by asivery

        ## HiMD

        ATTRS{idVendor}=="5341", ATTRS{idProduct}=="5256", TAG+="uaccess"
        ATTRS{idVendor}=="054c", ATTRS{idProduct}=="017e", TAG+="uaccess"
        ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0219", TAG+="uaccess"
        ATTRS{idVendor}=="054c", ATTRS{idProduct}=="021b", TAG+="uaccess"
        ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0186", TAG+="uaccess"
        ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0230", TAG+="uaccess"
        ATTRS{idVendor}=="054c", ATTRS{idProduct}=="022c", TAG+="uaccess"
        ATTRS{idVendor}=="054c", ATTRS{idProduct}=="01e9", TAG+="uaccess"
        ATTRS{idVendor}=="054c", ATTRS{idProduct}=="017f", TAG+="uaccess"
        ATTRS{idVendor}=="054c", ATTRS{idProduct}=="021a", TAG+="uaccess"
        ATTRS{idVendor}=="054c", ATTRS{idProduct}=="021c", TAG+="uaccess"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0187", MODE="0660", GROUP="plugdev", TAG+="uaccess"
        ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0231", TAG+="uaccess"
        ATTRS{idVendor}=="054c", ATTRS{idProduct}=="022d", TAG+="uaccess"
        ATTRS{idVendor}=="054c", ATTRS{idProduct}=="01ea", TAG+="uaccess"
        ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0180", TAG+="uaccess"
        ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0182", TAG+="uaccess"
        ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0184", TAG+="uaccess"
        ATTRS{idVendor}=="054c", ATTRS{idProduct}=="023c", TAG+="uaccess"
        ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0286", TAG+="uaccess"
        ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0287", TAG+="uaccess"


        ## NetMD

        # Aiwa AM-NX1
        ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0113", TAG+="uaccess"

        # Aiwa AM-NX9
        ATTRS{idVendor}=="054c", ATTRS{idProduct}=="014c", TAG+="uaccess"

        # Sharp IM-MT880H/MT899H
        ATTRS{idVendor}=="04dd", ATTRS{idProduct}=="7202", TAG+="uaccess"

        # Sharp IM-DR400/DR410
        ATTRS{idVendor}=="04dd", ATTRS{idProduct}=="9013", TAG+="uaccess"

        # Sharp IM-DR420/DR80/DR580 - Kenwood DMC-S9NET
        ATTRS{idVendor}=="04dd", ATTRS{idProduct}=="9014", TAG+="uaccess"

        # Sony NetMD (unknown model)
        ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0036", TAG+="uaccess"

        # Sony NetMD MZ-N1
        ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0075", TAG+="uaccess"

        # Sony NetMD (unknown model)
        ATTRS{idVendor}=="054c", ATTRS{idProduct}=="007c", TAG+="uaccess"

        # Sony NetMD LAM-1
        ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0080", TAG+="uaccess"

        # Sony NetMD MDS-JE780/JB980
        ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0081", TAG+="uaccess"

        # Sony MZ-N505
        ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0084", TAG+="uaccess"

        # Sony NetMD MZ-S1
        ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0085", TAG+="uaccess"

        # Sony NetMD MZ-N707
        ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0086", TAG+="uaccess"

        # Sony MZ-N10
        ATTRS{idVendor}=="054c", ATTRS{idProduct}=="00c6", TAG+="uaccess"

        # Sony NetMD MZ-N910
        ATTRS{idVendor}=="054c", ATTRS{idProduct}=="00c7", TAG+="uaccess"

        # Sony NetMD MZ-N710/NF810/NE810
        ATTRS{idVendor}=="054c", ATTRS{idProduct}=="00c8", TAG+="uaccess"

        # Sony NetMD MZ-N510/NF610
        ATTRS{idVendor}=="054c", ATTRS{idProduct}=="00c9", TAG+="uaccess"

        # Sony MZ-N410/NF520D
        ATTRS{idVendor}=="054c", ATTRS{idProduct}=="00ca", TAG+="uaccess"

        # Sony NetMD MZ-NE810/NE910/DN430
        ATTRS{idVendor}=="054c", ATTRS{idProduct}=="00eb", TAG+="uaccess"

        # Sony NetMD LAM-10
        ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0101", TAG+="uaccess"

        # Sony MZ-N920
        ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0188", TAG+="uaccess"

        # Sony NetMD LAM-3
        ATTRS{idVendor}=="054c", ATTRS{idProduct}=="018a", TAG+="uaccess"

        # Sony NetMD CMT-AH10
        ATTRS{idVendor}=="054c", ATTRS{idProduct}=="021d", TAG+="uaccess"

        # Panasonic NetMD SJ-MR250
        ATTRS{idVendor}=="04da", ATTRS{idProduct}=="23b3", TAG+="uaccess"

        # Sony CMT-M333NT
        ATTRS{idVendor}=="054c", ATTRS{idProduct}=="00e7", TAG+="uaccess"
      '';
    };
    mysql = {
      enable = true;
      package = pkgs.mariadb;
    };
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
  };

  users.users.mpennington = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" "dialout" "audio" "video"]; # Enable ‘sudo’ for the user.
  };

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 1w";
    };
    settings = {
      auto-optimise-store = true;
      trusted-users = ["root" "mpennington"];
      experimental-features = ["nix-command" "flakes"];
    };
  };

  environment.systemPackages = with pkgs; [
    inputs.alejandra.defaultPackage.${system}
    inputs.nixd.packages.${system}.default
    wineWowPackages.waylandFull
    winetricks
    bat
    file
    nodePackages.js-beautify
    unzip
    bottom
    eza
    fd
    gcc
    gh
    packwiz
    ripgrep
    black
    isort
    rustup
    parallel
    prettier
    gnumake
    usbutils
    stow
    vscode-extensions.vadimcn.vscode-lldb
    w3m
    wget
    xdg-user-dirs
    (let
      base = pkgs.appimageTools.defaultFhsEnvArgs;
    in
      pkgs.buildFHSEnv (base
        // {
          name = "fhs";
          targetPkgs = pkgs:
          # pkgs.buildFHSUserEnv provides only a minimal FHS environment,
          # lacking many basic packages needed by most software.
          # Therefore, we need to add them manually.
          #
          # pkgs.appimageTools provides basic packages required by most software.
            (base.targetPkgs pkgs)
            ++ (
              with pkgs; [
                pkg-config
                ncurses
                nodejs
                wineWowPackages.stable
              ]
            );
          profile = "export FHS=1";
          runScript = "bash";
          extraOutputsToInstall = ["dev"];
        }))
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
    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    };
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        squashfsTools
        glib
        nss
        cups
        libdrm
        gdk-pixbuf
        gtk3
        pango
        cairo
        xorg.libX11
        xorg.libXcomposite
        xorg.libXdamage
        xorg.libXext
        xorg.libXfixes
        xorg.libXrandr
        xorg.libxcb
        libxkbcommon
        alsa-lib
        libgbm
        expat
        nspr
        dbus
        at-spi2-atk
      ];
    };
    fish.enable = true;
    git.enable = true;
    nixvim = {
      enable = true;
      defaultEditor = true;
      extraPlugins = [pkgs.vimPlugins.phha-zenburn];
      colorscheme = "zenburn";
      highlightOverride = let
        opts = {
          ctermbg = null;
          guibg = null;
        };
      in {
        LspInlayHint = {
          fg = "#9DA9A0";
        };
        LineNr = opts;
        FoldColumn = opts;
        NonText = opts;
        Normal = opts;
      };
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
              python = ["isort" "black"];
              html = ["html_beautify"];
              css = ["css_beautify"];
              ts = ["prettier"];
            };
            formatters.html_beautify = {
              prepend_args = ["-w" "80" "-s" "2"];
            };
            format_on_save = {
              lsp_format = "fallback";
              timeout_ms = 500;
            };
          };
        };
        web-devicons.enable = true;
        transparent.enable = true;
        typescript-tools.enable = true;
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
            html.enable = true;
            cssls.enable = true;
            # ts_ls.enable = true;
            pylsp.enable = true;
            clangd.enable = true;
            bashls.enable = true;
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
        dap-ui = {
          enable = true;
          luaConfig.post =
            # Lua
            ''
              local dap, dapui = require("dap"), require("dapui")
              dap.listeners.before.attach.dapui_config = function()
                dapui.open()
              end
              dap.listeners.before.launch.dapui_config = function()
                dapui.open()
              end
              dap.listeners.before.event_terminated.dapui_config = function()
                dapui.close()
              end
              dap.listeners.before.event_exited.dapui_config = function()
                dapui.close()
              end
            '';
        };
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
