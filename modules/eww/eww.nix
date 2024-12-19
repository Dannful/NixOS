{ lib, pkgs, ... }:

with lib;

let cfg = config.programs.eww;
in {
  options.programs.eww = {
    enable = mkEnableOption "EWW bar";

    css = mkOption {
      type = types.lines;
      description = "CSS file to be used";
    };

    yuck = mkOption {
      type = types.lines;
      description = "EWW yuck file to be used";
    };
  };
  config = mkIf cfg.enable {
    home.packages = [ pkgs.eww ];
    home.file = {
      ".config/eww/eww.css" = { text = cfg.css; };
      ".config/eww/eww.yuck" = { text = cfg.yuck; };
    };
  };
}
