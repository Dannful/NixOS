{ config, system-config-flakes, hostname, pkgs, lib, ... }:

{
  imports = [
    # ./i3wm.nix
    # ../../modules/polybar/polybar.nix
    ../../modules/zed/zed.nix
    ../../modules/rofi/rofi.nix
    ../../modules/flameshot/flameshot.nix
    ../../modules/zsh/zsh.nix
    ./kitty.nix
    ./autorandr.nix
  ];
  xsession = {
    enable = true;
  };
  programs = {
    git = {
      enable = true;
      userName = "Vinícius Daniel";
      userEmail = "dannful@gmail.com";
    };
  };
}
