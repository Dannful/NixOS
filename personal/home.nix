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
    username = "dannly";
    homeDirectory = "/home/dannly";

    stateVersion = "24.05"; # Please read the comment before changing.

    packages = with pkgs; [
      gh
      lazygit
      obs-studio
      mono
      prismlauncher
      droidcam
      gemini-cli
      deluge
      logseq
    ];

    sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
    };
    file.".claude/CLAUDE.md" = {
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

        Host gppd-hpc.inf.ufrgs.br
          Hostname gppd-hpc.inf.ufrgs.br
          User vdspadotto
          IdentityFile ~/.ssh/pcad

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
    lsp = {
      servers = {
        ruby_lsp.cmd = pkgs.lib.mkForce ["ruby-lsp"];
        r-languageserver.cmd = pkgs.lib.mkForce ["R" "--no-echo" "-e" "languageserver::run()"];
        texlab = {
          enable = true;
          cmd = pkgs.lib.mkForce [(pkgs.lib.getExe pkgs.texlab)];
        };
      };
    };
    formatter.conform-nvim.setupOpts = {
      formatters_by_ft = {
        typescript = ["eslint_d"];
        typescriptreact = ["eslint_d"];
        javascript = ["eslint_d"];
        javascriptreact = ["eslint_d"];
        tex = ["tex-fmt"];
        bib = ["bibtex-tidy"];
      };
      formatters = {
        rubocop.command = pkgs.lib.mkForce "rubocop";
        eslint_d.command = pkgs.lib.getExe pkgs.eslint_d;
        "tex-fmt".command = pkgs.lib.getExe pkgs.tex-fmt;
        "bibtex-tidy".command = pkgs.lib.getExe pkgs.bibtex-tidy;
        styler.command = pkgs.lib.mkForce "R";
      };
    };
    languages = {
      clang.enable = true;
      r = {
        enable = true;
        format.type = ["styler"];
      };
      ruby = {
        enable = true;
        lsp.servers = ["ruby_lsp"];
      };
      ts = {
        enable = true;
        format.enable = false;
      };
    };
    lazy.plugins = {
      "iron.nvim" = {
        package = pkgs.vimPlugins.iron-nvim;
        setupModule = "iron.core";
        setupOpts = {
          config = {
            scratch_repl = true;
            repl_definition = {
              r = {
                command = ["R"];
              };
            };
            repl_open_cmd = "vertical botright 40 split";
          };
          keymaps = {};
          highlight = {
            italic = true;
          };
        };
      };
    };

    luaConfigRC = {
      r_iron_keymaps = ''
        vim.api.nvim_create_autocmd("FileType", {
          pattern = "r",
          desc = "Set up R-specific REPL keybindings",
          callback = function()
            local iron = require("iron.core")
            local map = vim.keymap.set

            -- 1. Toggle / Restart REPL
            map("n", "<leader>rr", "<cmd>IronRepl<cr>", { desc = "Toggle R REPL", buffer = true })
            map("n", "<leader>rR", "<cmd>IronRestart<cr>", { desc = "Restart R REPL", buffer = true })

            -- 2. Code Execution
            map("n", "<leader>rl", function()
              iron.send_line()
              vim.cmd("normal! j")
            end, { desc = "Send Line to R", buffer = true })

            map("n", "<leader>rf", iron.send_file, { desc = "Send File to R", buffer = true })
            map("v", "<leader>rs", iron.visual_send, { desc = "Send Selection to R", buffer = true })
            map("n", "<leader>rs", function() iron.run_motion("send_motion") end, { desc = "Send Motion to R", buffer = true })
          end
        })
        vim.api.nvim_create_user_command("RView", function(opts)
          local df_name = opts.args
          if df_name == "" then print("Usage: :RView <dataframe>"); return end

          -- 1. Construct R code to save to temp csv
          local cmd = string.format('write.csv(%s, file = "/tmp/nvim_r_view.csv", row.names = FALSE)', df_name)

          -- 2. Send to Iron
          require("iron.core").send(nil, cmd)

          -- 3. Open Visidata in a split
          vim.defer_fn(function()
            vim.cmd("vsplit | terminal ${pkgs.visidata}/bin/vd /tmp/nvim_r_view.csv")
          end, 500)
        end, { nargs = 1 })
      '';
    };
  };

  custom-kitty.enable = true;

  custom-hyprland = {
    enable = true;
    nvidia = true;
    monitors = [
      {
        name = "DP-4";
        resolution = "1920x1080";
        refresh-rate = "165.00";
        position = "0x0";
      }
      {
        name = "HDMI-A-2";
        resolution = "1920x1200";
        refresh-rate = "59.95";
        position = "1920x0";
      }
    ];
  };
}
