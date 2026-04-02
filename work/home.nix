{pkgs, ...}: {
  imports = [
    ../modules/hyprland/custom-hyprland.nix
    ../modules/kitty/custom-kitty.nix
    ../modules/git/git.nix
    ../modules/emacs/emacs.nix
    ../modules/nvim/nvim.nix
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };
  home = {
    username = "vinidan";
    homeDirectory = "/home/vinidan";

    stateVersion = "24.05"; # Please read the comment before changing.

    packages = with pkgs; [
      gh
      lazygit
      gemini-cli
    ];

    file."~/.claude/CLAUDE.md" = {
      text = ''
        # Global AI Instructions

        ## Environment & Tooling
        * **OS:** The host system is NixOS.
        * **Dependencies:** Assume any necessary derivation or package is readily available right off the bat. Do not suggest traditional package managers (e.g., apt, brew).

        ## Communication & Tone
        * **Tone:** Strictly professional, direct, and concise. Do not apologize or use conversational filler.
        * **Explanations:** Provide step-by-step breakdowns of logic, but keep the explanations brief and highly focused on the technical implementation.

        ## Coding Philosophy & Style
        * **Paradigms:** Adapt strictly to the host language and current project architecture (e.g., use OOP for Ruby, functional for Nix). Do not force paradigms that are non-idiomatic to the stack.
        * **Readability:** Write self-documenting code with clear variable/function naming. Use minimal comments, reserving them exclusively for highly complex or non-obvious logic.
        * **Naming Conventions:** Follow the standard idiomatic conventions of the specific language being used (e.g., camelCase for Java/TS, PascalCase for C#, snake_case for Ruby).
        * **Typing:** Enforce strict typing in all strongly typed languages. Do not use `any` or equivalent dynamic bypasses unless absolutely unavoidable.

        ## Error Handling
        * **Philosophy:** Silent errors are unacceptable.
        * **Practice:** Never write silent catch blocks. Fail fast, log errors clearly, and ensure exceptions bubble up appropriately.

        ## Workflow & Git
        * **Commits:** Strictly use Conventional Commits (e.g., `feat:`, `fix:`, `chore:`, `refactor:`).
        * **Attribution:** Absolutely avoid adding "Co-authored-by" or any other AI attribution tags in commits, PR descriptions, or code comments.
        * **Testing:** Do not write unit tests proactively. Only generate tests when explicitly requested.
      '';
    };
    file.".ssh/config" = {
      text = ''
        Host github.com
          Hostname ssh.github.com
          User git
          IdentityFile ~/.ssh/github

        Host bitbucket.org
          Hostname bitbucket.org
          User git
          IdentityFile ~/.ssh/bitbucket
      '';
    };
  };

  programs.home-manager = {
    enable = true;
  };
  programs.nvf.settings.vim = {
    formatter.conform-nvim.setupOpts = {
      formatters_by_ft = {
        typescript = ["eslint_d"];
        typescriptreact = ["eslint_d"];
        javascript = ["eslint_d"];
        javascriptreact = ["eslint_d"];
      };
      formatters = {
        rubocop.command = pkgs.lib.mkForce "rubocop";
        eslint_d.command = pkgs.lib.getExe pkgs.eslint_d;
      };
    };
    languages = {
      clang.enable = true;
      r.enable = true;
      ruby = {
        enable = true;
        lsp.servers = ["ruby_lsp"];
      };
      ts = {
        enable = true;
        format.enable = false;
      };
    };
    lsp = {
      servers = {
        ruby_lsp.cmd = pkgs.lib.mkForce ["ruby-lsp"];
      };
    };
  };

  custom-kitty.enable = true;

  custom-hyprland = {
    enable = true;
    nvidia = true;
  };
}
