{ lib, config, pkgs, inputs, ... }:

let
  inherit (lib) mkOption types;
  cfg = config.custom-hyprland;

  startupScript = pkgs.pkgs.writeShellScriptBin "start" ''
    ${
      inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default
    }/bin/quickshell &
    hypridle &
  '';
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
      swappy
      rofi
      playerctl
      inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
    home.file = {
      ".config/rofi/config.rasi" = { text = ''@theme "arthur"''; };
      ".config/quickshell" = {
        source = ../quickshell;
        recursive = true;
      };
      ".config/hypr/hypridle.conf" = {
        text = ''
          general {
              lock_cmd = pidof hyprlock || hyprlock       # avoid starting multiple hyprlock instances.
              before_sleep_cmd = loginctl lock-session    # lock before suspend.
              after_sleep_cmd = hyprctl dispatch dpms on  # to avoid having to press a key twice to turn on the display.
          }

          listener {
              timeout = 150                                # 2.5min.
              on-timeout = brightnessctl -s set 10         # set monitor backlight to minimum, avoid 0 on OLED monitor.
              on-resume = brightnessctl -r                 # monitor backlight restore.
          }

          listener {
              timeout = 300                                 # 5min
              on-timeout = loginctl lock-session            # lock screen when timeout has passed
          }

          listener {
              timeout = 330                                                     # 5.5min
              on-timeout = hyprctl dispatch dpms off                            # screen off when timeout has passed
              on-resume = hyprctl dispatch dpms on && brightnessctl -r          # screen on when activity is detected after timeout has fired.
          }

          listener {
              timeout = 1800                                # 30min
              on-timeout = systemctl suspend                # suspend pc
          }
        '';
      };
    };
    programs.hyprlock = { enable = true; };
    services.hypridle = { enable = true; };

    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;
      systemd.enable = false;
      package =
        inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;

      plugins =
        [ inputs.hyprland-plugins.packages."${pkgs.system}".borders-plus-plus ];

      extraConfig = lib.optionalString cfg.nvidia ''
        env=LIBVA_DRIVER_NAME,nvidia
        env=__GLX_VENDOR_LIBRARY_NAME,nvidia
        env=ELECTRON_OZONE_PLATFORM_HINT,auto
      '';

      settings = {
        "$mod" = "SUPER";
        "$alt" = "ALT";
        general = { gaps_out = "38, 18, 18, 60"; };
        cursor = { no_hardware_cursors = true; };
        input = {
          kb_layout = "us";
          kb_variant = "alt-intl";
        };
        decoration = { rounding = 3; };
        exec-once = "hyprctl dispatch exec ${startupScript}/bin/start";
        monitor = builtins.map (monitor:
          "${monitor.name}, ${monitor.resolution}@${monitor.refresh-rate}, ${monitor.position}, 1")
          cfg.monitors;
        bind = [
          "$alt, B, exec, hyprctl dispatch exec ${pkgs.firefox}/bin/firefox"
          "$alt, F, exec, hyprctl dispatch exec ${pkgs.nautilus}/bin/nautilus"
          "$alt, D, exec, hyprctl dispatch exec ${pkgs.discord}/bin/discord"
          "$mod, Return, exec, hyprctl dispatch exec ${pkgs.kitty}/bin/kitty"
          "$mod, D, exec, hyprctl dispatch exec '${pkgs.rofi}/bin/rofi -show drun'"
          "$mod, Q, exec, hyprctl kill"
          "$mod, C, killactive"
          "$mod, F, fullscreen"
          '', Print, exec, grim -g "$(slurp)" - | swappy -f -''
        ] ++ (builtins.concatLists (builtins.genList (i:
          let ws = i + 1;
          in [
            "$mod, code:1${toString i}, workspace, ${toString ws}"
            "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
          ]) 9));
        "plugin:borders-plus-plus" = {
          add_borders = 1;

          "col.border_1" = "rgb(112145)";

          border_size_1 = 6;

          natural_rounding = "yes";
        };
      };
    };
  };
}
