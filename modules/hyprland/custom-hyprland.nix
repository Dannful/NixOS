{ lib, config, pkgs, inputs, ... }:

let
  inherit (lib) mkOption types;
  cfg = config.custom-hyprland;
  wallpaperStrings = builtins.map(monitor:
    "${pkgs.swww}/bin/swww img ${monitor.wallpaper} -o \"${monitor.name}\" &"
  ) (builtins.filter(monitor: monitor.wallpaper != null) cfg.monitors);
  startupScript = pkgs.pkgs.writeShellScriptBin "start" ''
    ${pkgs.eww}/bin/eww open left_bar
    ${pkgs.eww}/bin/eww open bottom_bar

    ${pkgs.swww}/bin/swww init &
    sleep 1
    ${lib.strings.concatStringsSep "\n" wallpaperStrings}
  '';
in
{
  options.custom-hyprland = {
    enable = lib.mkEnableOption "Enable my custom Hyprland";
    monitors = mkOption {
      description = "A list containing all monitor configurations";
      type = types.listOf(types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            description = "Identifier of the monitor.";
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
          wallpaper = mkOption {
            type = types.nullOr types.path;
            description = "Wallpaper path for the monitor.";
            example = ./wallpaper.png;
          };
        };
      });
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.eww
      pkgs.swww
      pkgs.alsa-utils
      pkgs.grim
      pkgs.slurp
      pkgs.wl-clipboard
      pkgs.swappy
    ];
    services.mako = {
      enable = true;
      anchor = "top-right";
      font = "FiraCode Nerd Font 12";
    };
    wayland.windowManager.hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;

      plugins = [
        inputs.hyprland-plugins.packages."${pkgs.system}".borders-plus-plus
      ];

      settings = {
        "$mod" = "SUPER";
        "$alt" = "ALT";
        general = {
          gaps_out = "18, 18, 60, 60";
        };
        input = {
          kb_layout = "us";
          kb_variant = "alt-intl";
        };
        exec-once = ''${startupScript}/bin/start'';
        monitor = builtins.map(monitor:
          "${monitor.name}, ${monitor.resolution}@${monitor.refresh-rate}, ${monitor.position}, 1"
        ) cfg.monitors;
        bind = [
          "$alt, B, exec, ${pkgs.firefox}/bin/firefox"
          "$alt, D, exec, ${pkgs.discord}/bin/discord"
          "$mod, Return, exec, ${pkgs.kitty}/bin/kitty"
          "$mod, D, exec, ${pkgs.rofi-wayland}/bin/rofi -dmenu"
          "$mod, Q, exec, hyprctl kill"
	"$mod, Print, exec, grim -g \"$(slurp)\" - | swappy -f -"
        ]
        ++ (
          builtins.concatLists(builtins.genList (i:
            let ws = i + 1;
            in [
              "$mod, code:1${toString i}, workspace, ${toString ws}"
              "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
            ]
          )
          9)
        );
        "plugin:borders-plus-plus" = {
          add_borders = 1;

          "col.border_1" = "rgb(ffffff)";
          "col.border_2" = "rgb(2222ff)";

          border_size_1 = 6;
          border_size_2 = 3;

          natural_rounding = "yes";
        };
      };
    };
  };
}
