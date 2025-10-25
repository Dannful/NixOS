{ pkgs, inputs, ... }:

{
  imports = [
    ../modules/hyprland/custom-hyprland.nix
    ../modules/kitty/custom-kitty.nix
    ../modules/zed/zed.nix
    ../modules/git/git.nix
    ../modules/emacs/emacs.nix
    ../modules/nvim/nvim.nix
  ];

  home.username = "dannly";
  home.homeDirectory = "/home/dannly";

  nixpkgs = { config = { allowUnfree = true; }; };

  home.stateVersion = "24.05"; # Please read the comment before changing.

  home.packages = with pkgs; [
    gh
    lazygit
    obs-studio
    ferium
    mono
    prismlauncher
    corretto21
    droidcam
    gemini-cli
  ];

  home.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS =
      "\${HOME}/.steam/root/compatibilitytools.d";
  };

  programs.home-manager = { enable = true; };

  custom-kitty = {
    enable = true;
    wallpaper = ../modules/quickshell/wallpapers/frieren.png;
  };

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
