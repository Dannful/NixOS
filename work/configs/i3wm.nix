{ pkgs, lib, ... }:

{
  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;
    
    config = rec {
      modifier = "Mod4";
      bars = [ ];
      gaps = {
        inner = 15;
        outer = 5;
      };
      window.border = 0;

      keybindings = lib.mkOptionDefault {
        "${modifier}+b" = "exec ${pkgs.firefox}/bin/firefox";
        "${modifier}+Return" = "exec ${pkgs.kitty}/bin/kitty";
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
      ];
    };
  };
}
