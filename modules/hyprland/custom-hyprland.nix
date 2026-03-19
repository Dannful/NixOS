{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) mkOption types;
  cfg = config.custom-hyprland;
in {
  options.custom-hyprland = {
    enable = lib.mkEnableOption "custom Hyprland";
    nvidia = mkOption {
      description = "Whether to use NVIDIA";
      type = types.bool;
      default = false;
    };
    monitors = mkOption {
      description = "A list containing all monitor configurations";
      type = types.listOf (types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            description = "Name of the monitor.";
            example = "DP-1";
          };
          resolution = mkOption {
            type = types.str;
            description = "Resolution for the monitor.";
            example = "1920x1080";
          };
          refresh-rate = mkOption {
            type = types.str;
            description = "Refresh rate for the monitor.";
            example = "60.00";
          };
          position = mkOption {
            type = types.str;
            description = "The monitor's position.";
            example = "1920x0";
          };
        };
      });
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      alsa-utils
      grim
      slurp
      wl-clipboard
      cliphist
      swappy
      rofi
      playerctl
      brightnessctl
      inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
    home.file = {
      ".config/rofi/config.rasi" = {text = ''@theme "arthur"'';};
      ".config/quickshell" = {
        source = ../quickshell;
        recursive = true;
      };
    };
    programs.hyprlock.enable = true;
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
        };
        listener = [
          {
            timeout = 150;
            on-timeout = "brightnessctl -s set 10";
            on-resume = "brightnessctl -r";
          }
          {
            timeout = 300;
            on-timeout = "loginctl lock-session";
          }
          {
            timeout = 330;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on && brightnessctl -r";
          }
          {
            timeout = 1800;
            on-timeout = "systemctl suspend";
          }
        ];
      };
    };

    systemd.user.services.quickshell = {
      Unit = {
        Description = "Quickshell Panel";
        After = ["graphical-session-pre.target"];
        PartOf = ["graphical-session.target"];
      };
      Service = {
        ExecStart = "${inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/quickshell";
        Restart = "on-failure";
      };
      Install = {WantedBy = ["graphical-session.target"];};
    };

    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;
      systemd.enable = true;
      package =
        inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;

      extraConfig = lib.optionalString cfg.nvidia ''
        env=LIBVA_DRIVER_NAME,nvidia
        env=__GLX_VENDOR_LIBRARY_NAME,nvidia
        env=ELECTRON_OZONE_PLATFORM_HINT,auto
      '';

      settings = {
        "$mod" = "SUPER";
        "$alt" = "ALT";
        general = {
          gaps_in = 5;
          gaps_out = "58, 18, 18, 63";
          border_size = 2;
          "col.active_border" = "rgba(cba6f7ff) rgba(89b4faff) 45deg";
          "col.inactive_border" = "rgba(313244cc)";
          layout = "dwindle";
        };
        cursor = {no_hardware_cursors = true;};
        input = {
          kb_layout = "us";
          kb_variant = "alt-intl";
        };
        decoration = {
          rounding = 10;
          blur = {
            enabled = true;
            size = 4;
            passes = 3;
            new_optimizations = true;
            ignore_opacity = true;
          };
          shadow = {
            enabled = true;
            range = 10;
            render_power = 3;
            color = "rgba(1a1a1aee)";
          };
        };
        animations = {
          enabled = true;
          bezier = [
            "overshot, 0.05, 0.9, 0.1, 1.05"
            "smoothOut, 0.36, 0, 0.66, -0.56"
            "smoothIn, 0.25, 1, 0.5, 1"
          ];
          animation = [
            "windows, 1, 5, overshot, slide"
            "windowsOut, 1, 4, smoothOut, slide"
            "windowsMove, 1, 4, default"
            "border, 1, 10, default"
            "fade, 1, 10, smoothIn"
            "fadeDim, 1, 10, smoothIn"
            "workspaces, 1, 6, default"
          ];
        };
        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };
        exec-once = [
          "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store"
        ];
        monitor =
          builtins.map (monitor: "${monitor.name}, ${monitor.resolution}@${monitor.refresh-rate}, ${monitor.position}, 1")
          cfg.monitors;
        binds = {drag_threshold = 10;};
        bindm = ["$mod, mouse:272, movewindow" "$mod, mouse:273, resizewindow"];
        bindc = "$mod, mouse:272, togglefloating";
        bindel = [
          ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
          ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          ", XF86MonBrightnessUp, exec, ${pkgs.brightnessctl}/bin/brightnessctl s 10%+"
          ", XF86MonBrightnessDown, exec, ${pkgs.brightnessctl}/bin/brightnessctl s 10%-"
        ];
        bindl = [
          ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ", XF86AudioPlay, exec, playerctl play-pause"
          ", XF86AudioPrev, exec, playerctl previous"
          ", XF86AudioNext, exec, playerctl next"
        ];
        bind =
          [
            "$alt, B, exec, hyprctl dispatch exec ${pkgs.firefox}/bin/firefox"
            "$alt, F, exec, hyprctl dispatch exec ${pkgs.nautilus}/bin/nautilus"
            "$alt, D, exec, hyprctl dispatch exec ${pkgs.discord}/bin/discord"
            "$mod, Return, exec, hyprctl dispatch exec ${pkgs.kitty}/bin/kitty"
            "$mod, D, exec, hyprctl dispatch exec '${pkgs.rofi}/bin/rofi -show drun'"
            "$mod, Q, exec, hyprctl kill"
            "$mod, C, killactive"
            "$mod, F, fullscreen"
            '', Print, exec, grim -g "$(slurp)" - | swappy -f -''
            "$mod, V, exec, ${pkgs.cliphist}/bin/cliphist list | ${pkgs.rofi}/bin/rofi -dmenu -display-columns 2 | ${pkgs.cliphist}/bin/cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy"
            
            # Quick lock screen
            "$mod, L, exec, loginctl lock-session"
            
            # Window focus movement
            "$mod, left, movefocus, l"
            "$mod, right, movefocus, r"
            "$mod, up, movefocus, u"
            "$mod, down, movefocus, d"
            
            # Dwindle layout management
            "$mod, P, pseudo"
            
            # Scratchpad (special workspace)
            "$mod, S, togglespecialworkspace, magic"
            "$mod SHIFT, S, movetoworkspace, special:magic"

            # Scroll through existing workspaces with mouse
            "$mod, mouse_down, workspace, e+1"
            "$mod, mouse_up, workspace, e-1"
          ]
          ++ (builtins.concatLists (builtins.genList (i: let
              ws = i + 1;
            in [
              "$mod, code:1${toString i}, workspace, ${toString ws}"
              "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
            ])
            9));
      };
    };
  };
}
