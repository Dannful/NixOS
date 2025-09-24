{ pkgs, ... }:

{
  imports = [
    ../modules/kitty/custom-kitty.nix
    ../modules/zed/zed.nix
    ../modules/hyprland/custom-hyprland.nix
    ../modules/git/git.nix
    ../modules/emacs/emacs.nix
  ];
  home.username = "work";
  home.homeDirectory = "/home/work";

  home.stateVersion = "24.05";

  nixpkgs = { config = { allowUnfree = true; }; };

  home.packages = with pkgs; [
    gh
    lazygit
    awscli2
    bruno
    nomad
    jetbrains.datagrip
    droidcam
    ollama-cuda
    gemini
  ];

  home.sessionVariables = { NOMAD_ADDR = "http://52.67.92.147:4646"; };

  programs.home-manager.enable = true;

  custom-kitty = { enable = true; };

  custom-zed = { enable = true; };

  custom-hyprland = {
    enable = true;
    nvidia = true;
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
