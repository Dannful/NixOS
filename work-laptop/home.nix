{ pkgs, ... }:

{
  imports = [
    ../modules/kitty/custom-kitty.nix
    ../modules/zed/zed.nix
    ../modules/hyprland/custom-hyprland.nix
    ../modules/git/git.nix
  ];
  home.username = "vinidan";
  home.homeDirectory = "/home/vinidan";

  home.stateVersion = "24.05";

  nixpkgs = { config = { allowUnfree = true; }; };

  home.file.".ssh/config" = {
    text = ''
      Host github.com
        Hostname ssh.github.com
        Port 443
        User git
    '';
  };

  home.packages = [
    pkgs.gh
    pkgs.lazygit
    pkgs.awscli2
    pkgs.insomnia
    pkgs.jq
    pkgs.brightnessctl
    pkgs.nomad
    pkgs.jetbrains.datagrip
  ];

  home.sessionVariables = { NOMAD_ADDR = "http://52.67.92.147:4646"; };

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
      name = "eDP-1";
      id = 0;
      resolution = "1920x1080";
      refresh-rate = "60.00";
      position = "0x0";
      show-bars = true;
    }];
    bar = { show-battery = true; };
  };
}
