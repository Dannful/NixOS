{ pkgs, ... }:

{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-pgtk;
    extraPackages = epkgs: [
      epkgs.evil
      epkgs.vterm
      epkgs.doom-themes
      epkgs.ess
    ];
    extraConfig = ''
      (require 'evil)
      (evil-mode 1)
      (require 'vterm)
      (load-theme 'doom-one t)
      (org-babel-do-load-languages
       'org-babel-load-languages
       '((R . t)))
    '';
  };
}
