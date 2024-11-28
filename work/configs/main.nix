{ config, system-config-flakes, hostname, pkgs, lib, ... }:

{
  imports = [
    ./i3wm.nix
    ./rofi.nix
    ./polybar.nix
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
