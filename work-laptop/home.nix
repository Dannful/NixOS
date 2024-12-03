{ pkgs, ... }:

{
  imports = [
    ../modules/kitty/custom-kitty.nix
    ../modules/zed/zed.nix
    ../modules/hyprland/custom-hyprland.nix
    ../modules/git/git.nix
  ];
  home.username = "Vinícius Daniel";
  home.homeDirectory = "/home/Vinícius Daniel";

  home.stateVersion = "24.05";

  nixpkgs = { config = { allowUnfree = true; }; };

  home.packages = [
    pkgs.gh
    pkgs.lazygit
    pkgs.awscli2
    pkgs.insomnia
    pkgs.jq
    pkgs.omnisharp-roslyn
  ];

  home.sessionVariables = { };

  programs.home-manager.enable = true;

  custom-kitty = { enable = true; };

  custom-zed = {
    enable = true;
    lsp = {
      omnisharp = {
        path = "${pkgs.omnisharp-roslyn}/bin/OmniSharp";
        arguments = [ "-lsp" ];
      };
    };
  };

  custom-hyprland = {
    enable = true;
    monitors = [{
      name = "eDP";
      resolution = "1920x1080";
      refresh-rate = "60.00";
      position = "0x0";
      model = "AG323FWG3R3";
      show-bars = true;
    }];
  };
}
