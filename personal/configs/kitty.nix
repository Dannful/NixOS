{ pkgs, lib, ... }:

{
  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      package = (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; } );
      size = 12;
    };
    extraConfig = ''
background_image ~/Pictures/wallpapers/frieren.png
background_image_layout centered
background_opacity 0.3
    '';
  };
}
