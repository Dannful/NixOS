{ pkgs, ... }:

{
  imports = [
    ../modules/kitty/custom-kitty.nix
    ../modules/zed/zed.nix
    ../modules/hyprland/custom-hyprland.nix
    ../modules/git/git.nix
  ];
  home.username = "work";
  home.homeDirectory = "/home/work";

  home.stateVersion = "24.05";

  nixpkgs = { config = { allowUnfree = true; }; };

  home.packages = [
    pkgs.gh
    pkgs.lazygit
    pkgs.awscli2
    pkgs.dotnet-sdk_8
    pkgs.dotnet-aspnetcore_8
    pkgs.insomnia
  ];

  home.sessionVariables = { };

  programs.home-manager.enable = true;

  custom-kitty = { enable = true; };

  custom-hyprland = {
    enable = true;
    monitors = [
      {
        name = "DP-1";
        resolution = "1920x1080";
        refresh-rate = "165.00";
        position = "0x0";
      }
      {
        name = "HDMI-A-1";
        resolution = "1920x1200";
        refresh-rate = "59.95";
        position = "1920x0";
      }
    ];
  };
}
