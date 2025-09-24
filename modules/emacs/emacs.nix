# emacs-config.nix
{
  pkgs, ...
}:

{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-pgtk;
    extraPackages = epkgs: [ epkgs.evil ];
    extraConfig = ''
      (require 'evil)
      (evil-mode 1)
    '';
  };
}
