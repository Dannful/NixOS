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
            mode = ["n" "v"];
            action = "<cmd>lua require(\"fastaction\").code_action()<CR>";
            silent = true;
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
          theme = "catppuccin";
        };
        autocomplete.blink-cmp = {
          enable = true;
          mappings = {
            previous = "<C-k>";
            next = "<C-j>";
          };
        };

        treesitter.context.enable = true;

        lsp = {
          enable = true;
          formatOnSave = true;
          inlayHints.enable = true;
          lightbulb.enable = true;
          trouble.enable = true;
          otter-nvim.enable = true;
          nvim-docs-view.enable = true;
          mappings = {
            goToDeclaration = "gD";
            goToDefinition = "gd";
            renameSymbol = "gn";
          };
        };

        binds = {
          whichKey.enable = true;
          cheatsheet.enable = true;
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

        minimap.codewindow.enable = true;

        languages = {
          enableTreesitter = true;
          enableDAP = true;
          enableFormat = true;
          enableExtraDiagnostics = true;

          nix.enable = true;
          clang.enable = true;
          bash.enable = true;
          ts = {
            enable = true;
            format.type = "biome";
          };
          html.enable = true;
          terraform.enable = true;
          r.enable = true;
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
          motion = {
            flash-nvim.enable = true;
            precognition.enable = true;
          };
          oil-nvim.enable = true;
          nvim-biscuits.enable = true;
        };
        ui = {
          illuminate.enable = true;
          noice.enable = true;
          borders.enable = true;
          colorizer.enable = true;
          fastaction.enable = true;
          breadcrumbs = {
            enable = true;
            navbuddy.enable = true;
          };
        };
        notify = {
          nvim-notify.enable = true;
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
        lazy.plugins = {
          "neoscroll.nvim" = {
            package = pkgs.vimPlugins.neoscroll-nvim;
            setupModule = "neoscroll";
            event = ["BufEnter"];
          };
        };
        visuals = {
          fidget-nvim.enable = true;
          indent-blankline = {
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
        notes = {
          todo-comments.enable = true;
          neorg = {
            enable = true;
            setupOpts.load = {
              "core.defaults" = {};
              "core.completion" = {
                config = {
                  engine = "nvim-cmp";
                  name = "[Norg]";
                };
              };
              "core.integrations.nvim-cmp" = {};
              "core.concealer" = {config = {icon_preset = "diamond";};};
              "core.esupports.metagen" = {
                config = {
                  type = "auto";
                  update_date = true;
                };
              };
              "core.qol.toc" = {};
              "core.qol.todo_items" = {};
              "core.looking-glass" = {};
              "core.presenter" = {config = {zen_mode = "zen-mode";};};
              "core.export" = {};
              "core.export.markdown" = {config = {extensions = "all";};};
              "core.summary" = {};
              "core.tangle" = {config = {report_on_empty = false;};};
              "core.ui.calendar" = {};
            };
          };
        };
      };
    };
  };
}
