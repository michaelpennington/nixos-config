{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
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
    zathura
    wezterm
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
