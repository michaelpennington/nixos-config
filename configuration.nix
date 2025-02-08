# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  libbluray = pkgs.libbluray.override {
    withAACS = true;
    withBDplus = true;
    withJava = true;
  };
  vlc = pkgs.vlc.override {inherit libbluray;};
  packwiz = pkgs.buildGoModule {
    name = "packwiz";
    src = inputs.packwiz;
    vendorHash = "sha256-krdrLQHM///dtdlfEhvSUDV2QljvxFc2ouMVQVhN7A0=";
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

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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
    printing.enable = true;
    pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
    };
    ucodenix = {
      enable = true;
      cpuModelId = "00A20F12";
    };
    openssh.enable = true;
    gnome.gnome-keyring.enable = true;
    minecraft-servers = {
      enable = true;
      eula = true;

      servers = {
        solo_world = let
          inherit (inputs.nix-minecraft.lib) collectFilesAt;
          modpack = pkgs.fetchPackwizModpack {
            url = "https://github.com/michaelpennington/server_mods/raw/refs/heads/main/pack.toml";
            packHash = "sha256-nPkgkb7l0mYiPJmXR/HzIVBa1c9D3SOekBI2+J4DsU8=";
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
            level-name = "Survival World";
          };
          files = {
            "config" = "${modpack}/config";
          };
          jvmOpts = "-XX:+UnlockExperimentalVMOptions -XX:+UnlockDiagnosticVMOptions -XX:+AlwaysActAsServerClassMachine -XX:+AlwaysPreTouch -XX:+DisableExplicitGC -XX:+UseNUMA -XX:NmethodSweepActivity=1 -XX:ReservedCodeCacheSize=400M -XX:NonNMethodCodeHeapSize=12M -XX:ProfiledCodeHeapSize=194M -XX:NonProfiledCodeHeapSize=194M -XX:-DontCompileHugeMethods -XX:MaxNodeLimit=240000 -XX:NodeLimitFudgeFactor=8000 -XX:+UseVectorCmov -XX:+PerfDisableSharedMem -XX:+UseFastUnorderedTimeStamps -XX:+UseCriticalJavaThreadPriority -XX:ThreadPriorityPolicy=1 -XX:+UseZGC -XX:AllocatePrefetchStyle=1 -XX:-ZProactive -Xms8G -Xmx8G -XX:+UseTransparentHugePages -XX:ConcGCThreads=10";
        };
      };
    };
  };

  users.users.mpennington = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager"]; # Enable ‘sudo’ for the user.
  };

  nix.settings.experimental-features = ["nix-command" "flakes"];

  environment.systemPackages = with pkgs; [
    inputs.alejandra.defaultPackage.${system}
    bat
    eza
    fd
    gcc
    gh
    packwiz
    ripgrep
    rustup
    stow
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
            };
            format_on_save = {
              lsp_format = "fallback";
              timeout_ms = 500;
            };
          };
        };
        web-devicons.enable = true;
        transparent.enable = true;
        lualine = {
          enable = true;
          settings.options.theme = "zenburn";
        };
        comment.enable = true;
      };
      keymaps = [
        {
          action = ":Neotree filesystem toggle<CR>";
          key = "<leader>e";
          mode = "n";
          options = {
            silent = true;
            desc = "Toggle neotree";
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
