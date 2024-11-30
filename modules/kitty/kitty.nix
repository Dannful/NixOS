{ pkgs, lib, ... }:

{
  programs.kitty = {
    enable = true;
    font = {
      name = "FiraCode Nerd Font";
      size = 12;
    };
    extraConfig = ''
background_image ~/Pictures/wallpapers/frieren.png
background_image_layout centered
background_opacity 0.3
draw_minimal_borders yes
window_padding_width 3
window_border_width 0
hide_window_decorations yes
active_border_color none
    '';
  };
}
