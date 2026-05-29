{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  # Custom Systemd Services
  systemd.user.services.bg = {
    Unit = {
      Description = "Set wallpaper to bing image of the day";
      BindsTo = ["sway-session.target"];
    };
    Service = {
      Type = "oneshot";
      WorkingDirectory = "${config.home.homeDirectory}/Pictures/Wallpapers/";
      ExecStart = [
        "${lib.meta.getExe pkgs.bingpot}"
        "${pkgs.sway}/bin/swaymsg output \"*\" bg ${config.home.homeDirectory}/Pictures/Wallpapers/wallpaper.jpg fill"
      ];
    };
    Install = {
      WantedBy = ["sway-session.target"];
    };
  };

  # Graphical User Interface Packages
  home.packages = with pkgs; [
    wl-clipboard
    qpwgraph
    sov
    polkit_gnome
    pavucontrol
    playerctl
    sway-launcher-desktop
    wlogout
    wob
    slurp
    grim
    imv
  ];

  # Status Bar Configuration
  programs.waybar = {
    enable = true;
    systemd = {
      enable = true;
      targets = ["sway-session.target"];
    };
  };

  xdg.configFile."waybar/config".source = ./configs/waybar/config;
  xdg.configFile."waybar/style.css".source = ./configs/waybar/style.css;

  # Document Viewer
  programs.zathura = {
    enable = true;
    extraConfig = ''
      map [normal] J scroll down
      map [normal] K scroll up
      map [normal] j navigate next
      map [normal] k navigate previous
      map [fullscreen] J scroll down
      map [fullscreen] K scroll up
      map [fullscreen] j navigate next
      map [fullscreen] k navigate previous
    '';
  };

  # Terminal Emulator
  programs.wezterm = {
    enable = true;
    extraConfig = builtins.readFile ./configs/wezterm/wezterm.lua;
  };
  xdg.configFile."wezterm/colors".source = ./configs/wezterm/colors;

  # Idle and Power Management
  services.swayidle = let
    display = status: "${pkgs.sway}/bin/swaymsg 'output * power ${status}'";
  in {
    enable = true;
    timeouts = [
      {
        timeout = 300;
        command = display "off";
        resumeCommand = display "on";
      }
      {
        timeout = 1800;
        command = "${pkgs.systemd}/bin/systemctl suspend";
      }
    ];
    events = {
      "before-sleep" = display "off";
      "after-resume" = display "on";
      "lock" = display "off";
      "unlock" = display "on";
    };
  };

  # Sway Window Manager Configuration
  wayland.windowManager.sway = {
    enable = true;
    checkConfig = false;
    extraConfig = builtins.readFile ./sway_config;
    package = null; # Handled by the system module
    systemd.enable = true;
    wrapperFeatures.gtk = true;

    config = let
      wezterm = lib.meta.getExe pkgs.wezterm;
      swayLauncherDesktop = lib.meta.getExe pkgs.sway-launcher-desktop;
    in {
      bars = []; # Using Waybar instead
      modifier = "Mod4"; # Super key
      terminal = "${wezterm}";
      menu = "${wezterm} start --class \"launcher\" -- ${swayLauncherDesktop}";

      startup = [
        {command = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";}
      ];

      # Custom Keybindings
      keybindings = let
        modifier = config.wayland.windowManager.sway.config.modifier;
        playerctl = lib.meta.getExe pkgs.playerctl;
        pactl = lib.meta.getExe' pkgs.pulseaudio "pactl";
        wlogout = lib.meta.getExe pkgs.wlogout;
      in
        lib.mkOptionDefault {
          # Media controls
          "${modifier}+Shift+c" = "exec ${playerctl} play-pause";
          "${modifier}+Shift+v" = "exec ${playerctl} next";
          "${modifier}+Shift+x" = "exec ${playerctl} previous";

          # Volume controls
          "XF86AudioRaiseVolume" = "exec ${pactl} set-sink-volume @DEFAULT_SINK@ +5%";
          "XF86AudioLowerVolume" = "exec ${pactl} set-sink-volume @DEFAULT_SINK@ -5%";

          # Session management
          "${modifier}+Shift+p" = "reload";
          "${modifier}+Shift+e" = "exec ${wlogout}";
        };

      # Window rules and aesthetics
      window = {
        border = 0;
        titlebar = false;
        commands = [
          {
            command = "floating enable, sticky enable, resize set 30ppt 60ppt, border pixel 5";
            criteria = {
              app_id = "^launcher$";
            };
          }
        ];
      };

      gaps = {
        inner = 15;
        outer = 20;
      };

      # Input device configuration
      input = {
        "type:keyboard" = {
          repeat_delay = "300";
          repeat_rate = "30";
          xkb_options = "compose:ralt";
        };
      };
    };
  };
}
