{ pkgs, lib, config, ... }:

let
  inherit (lib) mkOption types;
  cfg = config.custom-kitty;
in {
  imports = [ ../fish/fish.nix ];
  options.custom-kitty = {
    enable = lib.mkEnableOption "custom Kitty";
    wallpaper = mkOption {
      type = types.nullOr types.path;
      description = "Path to the wallpaper image.";
      example = ./wallpaper.png;
      default = null;
    };
  };
  config = lib.mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      font = {
        name = "FiraCode Nerd Font";
        size = 12;
      };
      extraConfig = ''
              ${
                if (cfg.wallpaper != null) then ''
                  background_image ${cfg.wallpaper}
                  background_image_layout centered
                  background_opacity 0.3'' else
                  ""
              }
        draw_minimal_borders yes
        window_padding_width 3
        window_border_width 0
        hide_window_decorations yes
        active_border_color none
        shell ${pkgs.fish}/bin/fish
      '';
    };
  };
}
