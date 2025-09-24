{ pkgs, ... }:

{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-pgtk;
    extraPackages = epkgs: [ epkgs.evil epkgs.vterm ];
    extraConfig = ''
      (require 'evil)
      (evil-mode 1)
      (require 'vterm)
    '';
  };
}
