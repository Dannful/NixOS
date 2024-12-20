{ lib, config, pkgs, inputs, ... }:

let
  inherit (lib) mkOption types;
  cfg = config.custom-hyprland;
  wallpaperStrings = builtins.map (monitor:
    ''${pkgs.swww}/bin/swww img ${monitor.wallpaper} -o "${monitor.name}" &'')
    (builtins.filter (monitor: monitor.wallpaper != null) cfg.monitors);
  startupScript = pkgs.pkgs.writeShellScriptBin "start" ''
    ${pkgs.eww}/bin/eww open left_bar
    ${pkgs.eww}/bin/eww open bottom_bar

    ${pkgs.swww}/bin/swww init &
    sleep 1
    ${lib.strings.concatStringsSep "\n" wallpaperStrings}
  '';
in {
  imports = [ ../eww/eww.nix ];
  options.custom-hyprland = {
    enable = lib.mkEnableOption "custom Hyprland";
    bar = mkOption {
      description = "EWW bar configuration";
      default = { show-battery = false; };
      type = types.submodule {
        options = {
          show-battery = mkOption {
            type = types.bool;
            default = false;
            example = true;
            description = "Whether or not to show battery bar.";
          };
        };
      };
    };
    monitors = mkOption {
      description = "A list containing all monitor configurations";
      type = types.listOf (types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            description = "Identifier of the monitor.";
            example = "DP-1";
          };
          model = mkOption {
            type = types.str;
            description = "Model of the monitor.";
            example = "SyncMaster";
          };
          show-bars = mkOption {
            type = types.bool;
            description =
              "Whether or not eww bars should be visible on this monitor.";
            default = false;
            example = true;
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
          wallpaper = mkOption {
            type = types.nullOr types.path;
            description = "Wallpaper path for the monitor.";
            example = ./wallpaper.png;
            default = null;
          };
        };
      });
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.swww
      pkgs.alsa-utils
      pkgs.grim
      pkgs.slurp
      pkgs.wl-clipboard
      pkgs.swappy
      pkgs.rofi-wayland
      pkgs.playerctl
    ];
    home.file.".config/rofi/config.rasi" = { text = ''@theme "arthur"''; };
    services.mako = {
      enable = true;
      anchor = "top-right";
      font = "FiraCode Nerd Font 12";
    };
    programs.eww-bar = {
      enable = true;
      css = ''
        * {
          all: unset; // Unsets everything so you can style everything from scratch
        }

        // Global Styles
        .bottom_bar {
          background-color: #112145;
          color: #b0b4bc;
          padding: 6px 9px 6px 9px;
        }

        .left_bar {
          background-color: #1a1145;
          color: #b0b4bc;
          padding: 9px;
          border-radius: 18px;
        }

        // Styles on classes (see eww.yuck for more information)

        .sidestuff slider {
          all: unset;
          color: #ffd5cd;
        }

        .metric scale trough highlight {
          all: unset;
          background-color: #d35d6e;
          color: #000000;
          border-radius: 9px;
        }

        .metric scale trough {
          all: unset;
          background-color: #4e4e4e;
          border-radius: 50px;
          min-height: 90px;
          min-width: 3px;
          margin-bottom: 15px;
          margin-top: 15px;
        }

        .label-ram {
          font-size: large;
        }

        button:hover {
          color: #d35d6e;
        }
      '';
      yuck = ''
        (defwidget left_bar []
          (centerbox :orientation "v" :halign "center"
            (workspaces)
            (systray :orientation "v" :spacing 3 :space-evenly true)
            (sidestuff)))

        (defwidget bottom_bar []
          (centerbox :orientation "h"
            (powermenu)
            (label :text time :halign "center")
            (music)))

        (defwidget powermenu []
          (box :class "powermenu"
               :orientation "h"
               :halign "start"
               :spacing 6
            ${
              if (cfg.bar.show-battery) then
                ''(label :text "  ''${battery_level}%")''
              else
                ""
            }
            (box :class "powerbuttons"
                :orientation "h"
                :halign "start"
                :spacing 24
              (button :onclick "systemctl poweroff" "⏻")
              (button :onclick "systemctl reboot" "󰜉")
              (button :onclick "hyprctl dispatch exit" "")
              (button :onclick "systemctl suspend" "")))
        )

        (defwidget sidestuff []
          (box :class "sidestuff" :orientation "v" :space-evenly false
            (metric :label {volume == 0 ? " " : " "}
                    :value volume
                    :onchange "amixer sset Master {}%")
            (metric :label " "
                    :value {EWW_RAM.used_mem_perc}
                    :onchange "")
            (metric :label " "
                    :value {EWW_CPU.avg}
                    :onchange "")
            (metric :label "💾"
                    :value {round((1 - (EWW_DISK["/"].free / EWW_DISK["/"].total)) * 100, 0)}
                    :onchange "")))

        (defwidget tray []
          (systray  :class "tray"
                    :orientation "h"
                    :spacing 3))

        (defwidget workspaces []
          (box :class "workspaces"
              :orientation "v"
              :space-evenly true
              :valign "start"
              :spacing 9
            (for entry in "[1, 2, 3, 4, 5, 6, 7, 8, 9]"
              (button :css {entry == active_workspace ? "button {color: white;}" : ""} :onclick "hyprctl dispatch workspace $\{entry}" entry))))

        (defwidget music []
          (box :class "music"
               :orientation "h"
               :space-evenly false
               :halign "end"
            {music != "" ? "🎵 $\{music}" : ""}))


        (defwidget metric [label value onchange]
          (box :orientation "v"
               :class "metric"
               :space-evenly false
               :halign "center"
            (scale :min 0
                   :max 101
                   :flipped true
                   :orientation "v"
                   :active {onchange != ""}
                   :value value
                   :onchange onchange)
            (box :class "label" label)))

        (deflisten music :initial ""
          "playerctl --follow metadata --format '{{ artist }} - {{ title }}' || true")

        (defpoll volume :interval "300ms"
          "amixer sget Master | awk -F '[^0-9]+' '/Left:/{print $3}'")

        (defpoll time :interval "1s"
          "date '+%H:%M:%S %b %d, %Y'")

        (defpoll active_workspace :interval "300ms"
          "hyprctl activeworkspace | awk -F '[^0-9]+' '/ID/{print $3}'")

          ${
            if (cfg.bar.show-battery) then
              ''
                (defpoll battery_level :interval "1s" "acpi --battery | awk -F '[^0-9]+' '/, /{print $3}'")''
            else
              ""
          }

        (defwindow left_bar
          :monitor '${
            (builtins.toJSON (builtins.map (monitor: monitor.model)
              (builtins.filter (monitor: monitor.show-bars) cfg.monitors)))
          }'
          :windowtype "dock"
          :geometry (geometry :x "0%"
                              :y "0%"
                              :width "3px"
                              :height "90%"
                              :anchor "top left")
          :reserve (struts :side "left" :distance "4%")
          (left_bar))

        (defwindow bottom_bar
          :monitor '${
            (builtins.toJSON (builtins.map (monitor: monitor.model)
              (builtins.filter (monitor: monitor.show-bars) cfg.monitors)))
          }'
          :windowtype "dock"
          :geometry (geometry :x "0%"
                              :y "0%"
                              :width "100%"
                              :height "3px"
                              :anchor "bottom center")
          :reserve (struts :side "bottom" :distance "4%")
          (bottom_bar))
      '';
    };
    wayland.windowManager.hyprland = {
      enable = true;
      package =
        inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;

      plugins =
        [ inputs.hyprland-plugins.packages."${pkgs.system}".borders-plus-plus ];

      settings = {
        "$mod" = "SUPER";
        "$alt" = "ALT";
        general = { gaps_out = "18, 18, 60, 60"; };
        input = {
          kb_layout = "us";
          kb_variant = "alt-intl";
        };
        decoration = { rounding = 3; };
        exec-once = "${startupScript}/bin/start";
        monitor = builtins.map (monitor:
          "${monitor.name}, ${monitor.resolution}@${monitor.refresh-rate}, ${monitor.position}, 1")
          cfg.monitors;
        bind = [
          "$alt, B, exec, ${pkgs.firefox}/bin/firefox"
          "$alt, F, exec, ${pkgs.nautilus}/bin/nautilus"
          "$alt, D, exec, ${pkgs.webcord-vencord}/bin/webcord"
          "$mod, Return, exec, ${pkgs.kitty}/bin/kitty"
          "$mod, D, exec, ${pkgs.rofi-wayland}/bin/rofi -show drun"
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
