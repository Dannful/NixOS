{pkgs, ...}: {
  imports = [
    ../modules/kitty/custom-kitty.nix
    ../modules/zed/zed.nix
    ../modules/hyprland/custom-hyprland.nix
    ../modules/git/git.nix
    ../modules/emacs/emacs.nix
    ../modules/nvim/nvim.nix
  ];
  home = {
    username = "work";
    homeDirectory = "/home/work";

    stateVersion = "24.05";

    packages = with pkgs; [
      gh
      lazygit
      awscli2
      bruno
      nomad
      jetbrains.datagrip
      droidcam
      gemini-cli
    ];

    sessionVariables = {NOMAD_ADDR = "http://52.67.92.147:4646";};
  };

  nixpkgs = {config = {allowUnfree = true;};};

  programs.home-manager.enable = true;
  programs.nvf.settings.vim.languages.csharp.enable = true;

  custom-kitty = {enable = true;};

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
