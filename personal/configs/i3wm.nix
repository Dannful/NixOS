{ pkgs, lib, ... }:

let
  modifier = "Mod4";
  alt = "Mod1";
in {
  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;
    
    config = {
      modifier = "${modifier}";
      bars = [ ];
      gaps = {
        inner = 15;
        outer = 5;
      };
      window.border = 0;

      keybindings = lib.mkOptionDefault {
        "${alt}+b" = "exec ${pkgs.firefox}/bin/firefox";
	"${alt}+d" = "exec ${pkgs.discord}/bin/discord";
        "${modifier}+Return" = "exec ${pkgs.kitty}/bin/kitty";
        "${modifier}+d" = "exec ${pkgs.rofi}/bin/rofi -show drun";
        "Print" = "exec ${pkgs.flameshot}/bin/flameshot gui -c";
      };

      startup = [
        {
          command = "systemctl --user restart polybar.service";
          always = true;
          notification = false;
        }
        {
          command = "${pkgs.autorandr}/bin/autorandr default";
          always = false;
          notification = false;
        }
        {
          command = "${pkgs.feh}/bin/feh --bg-center ~/Pictures/wallpapers/ai.png ~/Pictures/wallpapers/undertaker.png";
          always = true;
          notification = false;
        }
      ];
    };
  };
}
