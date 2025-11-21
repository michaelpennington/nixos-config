# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: let
  packwiz = pkgs.buildGoModule {
    name = "packwiz";
    src = inputs.packwiz;
    vendorHash = "sha256-P1SsvHTYKUoPve9m1rloBfMxUNcDKr/YYU4dr4vZbTE=";
  };
in {
  imports = [
    ./hardware-configuration.nix
    inputs.nixvim.nixosModules.nixvim
    inputs.ucodenix.nixosModules.default
    inputs.nix-minecraft.nixosModules.minecraft-servers
  ];

  nixpkgs.overlays = [inputs.nix-minecraft.overlay];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "ventoy-1.1.07"
  ];
  # boot.loader.grub.configurationLimit = 10;

  # Perform garbage collection weekly to maintain low disk usage

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;
    }
  ];

  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = ["graphical-session.target"];
      wants = ["graphical-session.target"];
      after = ["graphical-session.target"];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };

  boot = {
    loader.systemd-boot = {
      enable = true;
      configurationLimit = 10;
      extraEntries = {
        "lfs.conf" = ''
          title LFS
          linux /EFI/lfs/vmlinuz-6.16.7-lfs-ml-12.4-28-systemd
          options root=PARTUUID=e415e6a5-6756-473d-bed4-ce8d41fbb929 rw
        '';
      };
    };
    loader.efi.canTouchEfiVariables = true;
    kernelParams = [
      "amd_pstate=guided"
      "microcode.amd_sha_check=off"
      "acpi_enforce_resources=lax"
      #       "amd_iommu=on"
      # "iommu=pt"
      # "vfio-pci.ids=1002:73bf"
    ];
    extraModprobeConfig = ''
      options it87 force_id=0x8628 ignore_resource_conflict=1
    '';
    kernel.sysctl = {
      "vm.swappiness" = 10;

      "vm.vfs_cache_pressure" = 50;
    };
  };
  powerManagement.cpuFreqGovernor = "schedutil";
  time.hardwareClockInLocalTime = true;

  # virtualisation = {
  #   libvirtd = {
  #     enable = true;
  #     qemu.runAsRoot = true;
  #     # qemuOvmf = pkgs.OVMFFull.fd;
  #   };
  #   # qemu = {
  #   #   enable = true;
  #   #   # Allow QEMU to access USB devices, etc.
  #   #   runAsRoot = true;
  #   # };
  #   # Enable UEFI (OVMF) support for the VM
  #   # efi.OVMF = pkgs.OVMF.fd;
  # };

  hardware = {
    graphics.enable = true;
    amdgpu.overdrive.enable = true;
  };

  networking.hostName = "poseidon";
  networking.networkmanager.enable = true;

  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; # use xkb.options in tty.
  };

  services = {
    fstrim.enable = true;
    udev = {
      enable = true;
      extraRules = ''
        # Set 'none' (noop) scheduler for all NVMe devices
        ACTION=="add|change", KERNEL=="nvme[0-9]*n[0-9]*", ATTR{queue/scheduler}="none"

        # Optional: Do the same for any non-rotational SATA devices (SSDs)
        ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="none"
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
      cpuModelId = "00A60F12";
    };
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    openssh = {
      enable = true;
    };
    gnome.gnome-keyring.enable = true;
    minecraft-servers = {
      enable = true;
      eula = true;

      servers = {
        solo_world = let
          modpack = pkgs.fetchPackwizModpack {
            url = "https://github.com/michaelpennington/server_mods/raw/refs/heads/main/pack.toml";
            packHash = "sha256-wTsTRRM8JwOaOyRqE6+uhvnSSFM4NU38iIpbtGK/Ozo=";
          };
          mcVersion = modpack.manifest.versions.minecraft;
          fabricVersion = modpack.manifest.versions.fabric;
          serverVersion = lib.replaceStrings ["."] ["_"] "fabric-${mcVersion}";
        in {
          enable = true;
          package = pkgs.fabricServers.${serverVersion}.override {loaderVersion = fabricVersion;};
          autoStart = false;
          symlinks = {
            "mods" = "${modpack}/mods";
          };
          serverProperties = {
            # level-name = "Survival World";
            difficulty = "hard";
            pause-when-empty-seconds = -1;
          };
          files = {
            "config" = "${modpack}/config";
          };
          jvmOpts = "-Xms8G -Xmx12G -XX:+UseZGC -XX:+ZGenerational -XX:SoftMaxHeapSize=10g -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:+PerfDisableSharedMem -XX:+UseDynamicNumberOfGCThreads";
        };
      };
    };
  };

  users = {
    users = {
      mpennington = {
        isNormalUser = true;
        extraGroups = ["wheel" "networkmanager" "dialout" "audio" "video" "libvirtd"]; # Enable ‘sudo’ for the user.
      };
      lfs = {
        isNormalUser = true;
        extraGroups = ["wheel" "networkmanager" "lfs"];
      };
    };
    groups = {
      lfs = {
        name = "lfs";
        members = ["lfs"];
      };
    };
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
    lm_sensors
    amdgpu_top
    linuxPackages.zenpower
    radeontop
    pciutils
    wineWowPackages.waylandFull
    winetricks
    virt-manager
    virtio-win
    bat
    file
    zip
    nodePackages.js-beautify
    unzip
    xmlstarlet
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
                bison
                python3
                gnumake
                gcc
                texinfo
                m4
                patch
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
    noto-fonts-color-emoji
    nerd-fonts.fantasque-sans-mono
    nerd-fonts.fira-code
  ];

  programs = {
    corectrl = {
      enable = true;
    };
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
              typescript = ["prettier"];
              xml = ["xmlstarlet"];
            };
            formatters.html_beautify = {
              prepend_args = ["-w" "100" "-s" "2"];
            };
            formatters.prettier = {
              command = lib.getExe pkgs.prettier;
              prepend_args = ["--print-width" "100" "--experimental-ternaries" "--trailing-comma=es5"];
            };
            formatters.css_beautify = {
              prepend_args = ["-w" "100" "-s" "2"];
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
          luaConfig.post = ''
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
