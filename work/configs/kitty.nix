{ pkgs, lib, ... }:

{
  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      package = (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; } );
      size = 12;
    };
  };
}
