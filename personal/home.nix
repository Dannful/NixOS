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
      visidata
      deluge
    ];

    sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
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
    lsp.servers.ruby_lsp.cmd = pkgs.lib.mkForce ["ruby-lsp"];
    formatter.conform-nvim.setupOpts = {
      formatters_by_ft = {
        typescript = ["eslint_d"];
        typescriptreact = ["eslint_d"];
        javascript = ["eslint_d"];
        javascriptreact = ["eslint_d"];
      };
      formatters.rubocop.command = pkgs.lib.mkForce "rubocop";
      formatters.eslint_d.command = pkgs.lib.getExe pkgs.eslint_d;
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
    lsp.servers.r_language_server.cmd = let
      customRPackages = [
        pkgs.rPackages.tidyverse
        pkgs.rPackages.janitor
        pkgs.rPackages.here
        pkgs.rPackages.DoE_base
        pkgs.rPackages.ggh4x
        pkgs.rPackages.plotly
      ];
      r-with-languageserver = pkgs.rWrapper.override {
        packages = [pkgs.rPackages.languageserver] ++ customRPackages;
      };
    in
      pkgs.lib.mkForce [
        (pkgs.lib.getExe r-with-languageserver)
        "--no-echo"
        "-e"
        "languageserver::run()"
      ];
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
