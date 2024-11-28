{ config, pkgs, ... }:

{
  imports = [ ./configs/main.nix ];
  home.username = "work";
  home.homeDirectory = "/home/work";

  home.stateVersion = "24.05";

  home.packages = [
    (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; } )
    pkgs.gh
    pkgs.lazygit
  ];

  home.file = {
  };

  home.sessionVariables = {
  };

  programs.home-manager.enable = true;
}
