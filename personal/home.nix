{pkgs, ...}: {
  imports = [
    ../modules/hyprland/custom-hyprland.nix
    ../modules/kitty/custom-kitty.nix
    ../modules/zed/zed.nix
    ../modules/git/git.nix
    ../modules/emacs/emacs.nix
    ../modules/nvim/nvim.nix
  ];

  nixpkgs = {config = {allowUnfree = true;};};
  home = {
    username = "dannly";
    homeDirectory = "/home/dannly";

    stateVersion = "24.05"; # Please read the comment before changing.

    packages = with pkgs; [
      gh
      lazygit
      obs-studio
      mono
      prismlauncher
      droidcam
      gemini-cli
    ];

    sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
    };
  };

  programs.home-manager = {enable = true;};

  custom-kitty.enable = true;

  custom-zed = {enable = true;};

  custom-hyprland = {
    enable = true;
    nvidia = true;
    monitors = [
      {
        name = "DP-4";
        resolution = "1920x1080";
        refresh-rate = "165.00";
        position = "0x0";
      }
      {
        name = "HDMI-A-2";
        resolution = "1920x1200";
        refresh-rate = "59.95";
        position = "1920x0";
      }
    ];
  };
}
