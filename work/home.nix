{ config, pkgs, ... }:

{
  imports = [ ./configs/main.nix ../modules/zsh/zsh.nix ];
  home.username = "work";
  home.homeDirectory = "/home/work";

  home.stateVersion = "24.05";

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  home.packages = [
    (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; } )
    pkgs.gh
    pkgs.lazygit
    pkgs.discord-ptb
    pkgs.awscli2
    pkgs.dotnet-sdk_8
    pkgs.dotnet-aspnetcore_8
  ];

  home.sessionVariables = {
  };

  programs.home-manager.enable = true;
}
