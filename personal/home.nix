{ pkgs, ... }:

{
  imports = [
    ../modules/hyprland/custom-hyprland.nix
    ../modules/kitty/custom-kitty.nix
    ../modules/zed/zed.nix
    ../modules/git/git.nix
  ];
  home.username = "dannly";
  home.homeDirectory = "/home/dannly";

  nixpkgs = { config = { allowUnfree = true; }; };

  home.stateVersion = "24.05"; # Please read the comment before changing.

  home.packages = [ pkgs.gh pkgs.lazygit pkgs.nixd pkgs.nixfmt-classic ];

  home.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS =
      "\${HOME}/.steam/root/compatibilitytools.d";
  };

  programs.home-manager = { enable = true; };

  custom-kitty = {
    enable = true;
    wallpaper = ./wallpapers/frieren.png;
  };

  custom-hyprland = {
    enable = true;
    monitors = [
      {
        name = "DP-1";
        wallpaper = ./wallpapers/ai.png;
        resolution = "1920x1080";
        refresh-rate = "165.00";
        position = "0x0";
        model = "AG323FWG3R3";
        show-bars = true;
      }
      {
        name = "HDMI-A-1";
        wallpaper = ./wallpapers/overlord.png;
        resolution = "1920x1200";
        refresh-rate = "59.95";
        position = "1920x0";
        model = "SyncMaster";
      }
    ];
  };
}
