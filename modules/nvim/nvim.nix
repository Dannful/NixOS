{
  pkgs,
  inputs,
  ...
}: {
  imports = [inputs.nvf.homeManagerModules.default];
  programs.nvf = {
    enable = true;
    settings = {
      vim = {
        viAlias = true;
        vimAlias = true;
        keymaps = [
          {
            key = "<leader>e";
            mode = ["n"];
            silent = true;
            action = "<cmd>Oil --float<CR>";
          }
          {
            key = "g.";
            mode = ["n"];
            silent = true;
            action = "require(\"actions-preview\").code_actions";
            lua = true;
          }
        ];
        theme = {
          enable = true;
          name = "catppuccin";
          style = "macchiato";
        };
        options = {
          tabstop = 2;
          shiftwidth = 2;
        };
        autopairs.nvim-autopairs.enable = true;
        statusline.lualine = {
          enable = true;
          theme = "ayu_dark";
        };
        autocomplete.nvim-cmp = {
          enable = true;
          mappings = {
            previous = "<C-k>";
            next = "<C-j>";
          };
        };

        lazy.plugins = {
          "neoscroll.nvim" = {
            package = pkgs.vimPlugins.neoscroll-nvim;
            setupModule = "neoscroll";
            event = ["BufEnter"];
          };
          "actions-preview.nvim" = {
            package = pkgs.vimPlugins.actions-preview-nvim;
            setupModule = "actions-preview";
            event = ["LspAttach"];
          };
        };

        lsp = {
          enable = true;
          formatOnSave = true;
          inlayHints.enable = true;
          lightbulb.enable = true;
          mappings = {
            goToDeclaration = "gD";
            goToDefinition = "gd";
            renameSymbol = "gn";
          };
        };

        telescope = {
          enable = true;
          mappings = {
            lspDocumentSymbols = "gs";
            lspImplementations = "gI";
            lspReferences = "gr";
            lspTypeDefinitions = "gt";
            lspWorkspaceSymbols = "gS";
          };
          extensions = [
            {
              name = "ui-select";
              packages = [pkgs.vimPlugins.telescope-ui-select-nvim];
            }
          ];
        };

        languages = {
          enableTreesitter = true;
          enableDAP = true;
          enableFormat = true;

          nix.enable = true;
          clang.enable = true;
          bash.enable = true;
          ts = {
            enable = true;
            format.type = "prettierd";
          };
        };
        terminal.toggleterm = {
          enable = true;
          lazygit.enable = true;
        };
        git.gitsigns = {
          enable = true;
          setupOpts = {
            current_line_blame = true;
          };
        };

        utility = {
          motion.flash-nvim.enable = true;
          oil-nvim.enable = true;
        };
        ui = {
          illuminate.enable = true;
          noice.enable = true;
        };
        comments.comment-nvim.enable = true;
        highlight = {
          "RainbowRed".fg = "#E06C75";
          "RainbowYellow".fg = "#E5C07B";
          "RainbowBlue".fg = "#61AFEF";
          "RainbowOrange".fg = "#D19A66";
          "RainbowGreen".fg = "#98C379";
          "RainbowViolet".fg = "#C678DD";
          "RainbowCyan".fg = "#56B6C2";
        };
        visuals.indent-blankline = {
          enable = true;
          setupOpts.indent.highlight = [
            "RainbowRed"
            "RainbowYellow"
            "RainbowBlue"
            "RainbowOrange"
            "RainbowGreen"
            "RainbowViolet"
            "RainbowCyan"
          ];
        };
      };
    };
  };
}
