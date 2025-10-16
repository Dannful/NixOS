{ pkgs, ... }:

{
  # Provides lintr and styler for emacs R formatting and linting
  home.packages = with pkgs; [
    rPackages.lintr
    rPackages.styler
  ];

  programs.emacs = {
    enable = true;
    package = pkgs.emacs-pgtk;
    extraPackages = epkgs: [
      epkgs.evil
      epkgs.vterm
      epkgs.doom-themes
      epkgs.ess
      epkgs.pdf-tools
      epkgs.flycheck
      epkgs.apheleia
    ];
    extraConfig = ''
      (require 'evil)
      (evil-mode 1)
      (require 'vterm)
      (load-theme 'doom-one t)
      (org-babel-do-load-languages
       'org-babel-load-languages
       '((R . t)
         (shell . t)))
      (setq org-confirm-babel-evaluate nil)
      (pdf-loader-install)
      (setq org-latex-listings 'minted)
      (setq org-latex-pdf-process '("latexmk -shell-escape -pdf %f"))
      (add-to-list 'org-latex-packages-alist '("" "tabularx"))
      (define-key org-mode-map (kbd "C-c C-v d") 'org-babel-remove-result)

      ;; R linter and formatter for org-mode blocks
      (require 'flycheck)
      (add-hook 'ess-mode-hook 'flycheck-mode)

      (require 'apheleia)
      (with-eval-after-load 'apheleia
        (setf (alist-get 'r-styler apheleia-formatters)
              '("Rscript" "-e" "styler::style_text(readLines(file(\"stdin\")))"))
        (add-to-list 'apheleia-mode-alist '(ess-r-mode . r-styler)))
      (add-hook 'before-save-hook 'apheleia-format-buffer nil t)
    '';
  };
}
