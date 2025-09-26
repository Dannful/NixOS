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
      epkgs.pdf-tools
    ];
    extraConfig = ''
      (require 'evil)
      (evil-mode 1)
      (require 'vterm)
      (load-theme 'doom-one t)
      (org-babel-do-load-languages
       'org-babel-load-languages
       '((R . t)))
      (setq org-confirm-babel-evaluate nil)
      (pdf-loader-install)
      (setq org-latex-listings 'minted)
      (setq org-latex-pdf-process '("latexmk -shell-escape -pdf %f"))
      (add-to-list 'org-latex-packages-alist '("" "tabularx"))
      (define-key org-mode-map (kbd "C-c C-v d") 'org-babel-remove-result)
    '';
  };
}
