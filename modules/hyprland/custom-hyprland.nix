{ lib, config, pkgs, inputs, ... }:

let
  inherit (lib) mkOption types;
  cfg = config.custom-hyprland;
  gruvboxPlus = import ./gruvbox-plus.nix {
    inherit pkgs;
    inherit lib;
  };
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

  buildEwwDirectory = sourceDir: outputDir:
    let dir = builtins.readDir sourceDir;
    in (builtins.foldl' (first: second: first // second) { } (builtins.map
      (name:
        if (lib.strings.hasSuffix ".jpg" name)
        || (lib.strings.hasSuffix ".png" name) then {
          "${outputDir}/${name}" = { source = "${sourceDir}/${name}"; };
        } else if (builtins.getAttr name dir) != "directory" then {
          "${outputDir}/${name}" = {
            text = (builtins.replaceStrings [
              "{MONITORS}"
              "{BASH_BIN}"
              "{EWW_BIN}"
            ] [
              (builtins.toJSON (builtins.map (monitor: monitor.id)
                (builtins.filter (monitor: monitor.show-bars) cfg.monitors)))
              "${pkgs.bash}/bin/bash"
              "${pkgs.eww}/bin/eww"
            ] (builtins.readFile "${sourceDir}/${name}"));
            executable =
              if (lib.strings.hasSuffix ".sh" name) then true else false;
          };
        } else
          (buildEwwDirectory "${sourceDir}/${name}" "${outputDir}/${name}"))
      (builtins.attrNames dir)));
in {
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
            description = "Name of the monitor.";
            example = "DP-1";
          };
          id = mkOption {
            type = types.ints.u8;
            description = "Identifier of the monitor.";
            example = 0;
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
      pkgs.eww
    ];
    home.file = lib.mkMerge [
      { ".config/rofi/config.rasi" = { text = ''@theme "arthur"''; }; }
      (buildEwwDirectory (./.. + "/eww") ".config/eww")
    ];
    services.mako = {
      enable = true;
      anchor = "top-right";
      font = "FiraCode Nerd Font 12";
    };
    qt = {
      enable = true;
      platformTheme.name = "gtk";
      style = {
        name = "adwaita-dark";
        package = pkgs.adwaita-qt;
      };
    };

    gtk.enable = true;

    gtk.cursorTheme.package = pkgs.bibata-cursors;
    gtk.cursorTheme.name = "Bibata-Modern-Ice";

    gtk.theme.package = pkgs.adw-gtk3;
    gtk.theme.name = "adw-gtk3";

    gtk.iconTheme.package = gruvboxPlus;
    gtk.iconTheme.name = "GruvboxPlus";

    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;
      package =
        inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;

      plugins =
        [ inputs.hyprland-plugins.packages."${pkgs.system}".borders-plus-plus ];

      settings = {
        "$mod" = "SUPER";
        "$alt" = "ALT";
        general = { gaps_out = "18, 18, 60, 60"; };
        cursor = { no_hardware_cursors = true; };
        render = {
          explicit_sync = 0;
          explicit_sync_kms = 0;
        };
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
