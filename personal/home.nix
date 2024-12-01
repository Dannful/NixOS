{ config, pkgs, inputs, ... }:

let
  startupScript = pkgs.pkgs.writeShellScriptBin "start" ''
    ${pkgs.eww}/bin/eww open left_bar
    ${pkgs.eww}/bin/eww open bottom_bar

    ${pkgs.swww}/bin/swww init &
    sleep 1
    ${pkgs.swww}/bin/swww img ${configs/wallpapers/ai.png} -o "DP-1" &
    ${pkgs.swww}/bin/swww img ${configs/wallpapers/overlord.png} -o "HDMI-A-1" &
  '';
in
{
  imports = [ ./configs/main.nix ../modules/zsh/zsh.nix ../modules/hyprland/custom-hyprland.nix ];
  home.username = "dannly";
  home.homeDirectory = "/home/dannly";

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  home.stateVersion = "24.05"; # Please read the comment before changing.

  home.packages = [
    pkgs.feh
    pkgs.gh
    pkgs.lazygit
    pkgs.discord-ptb
    pkgs.eww
    pkgs.swww
    pkgs.playerctl
    pkgs.pamixer
    pkgs.alsa-utils
  ];

  home.file."Pictures/wallpapers" = {
    source = ./configs/wallpapers;
    recursive = true;
  };

  home.file.".config/eww" = {
    source = ../modules/eww;
    recursive = true;
  };

  home.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
  };

  programs.home-manager = {
    enable = true;
  };

  custom-hyprland = {
    enable = true;
    monitors = [
      {
        name = "DP-1";
        wallpaper = ./configs/wallpapers/ai.png;
        resolution = "1920x1080";
        refresh-rate = "165.00";
        position = "0x0";
      }
      {
        name = "HDMI-A-1";
        wallpaper = ./configs/wallpapers/overlord.png;
        resolution = "1920x1200";
        refresh-rate = "59.95";
        position = "1920x0";
      }
    ];
  };
}
