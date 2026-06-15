{
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [inputs.nvf.homeManagerModules.default];
  home.packages = [pkgs.ripgrep];

  programs.nvf = {
    enable = true;
    settings = {
      vim = {
        viAlias = true;
        vimAlias = true;

        opts.expandtab = true;

        spellcheck = {
          enable = true;
          languages = [
            "en"
            "pt_br"
          ];
        };
        keymaps = [
          {
            key = "<leader>gr";
            mode = ["n"];
            action = "<cmd>lua require('grug-far').open({ transient = true, prefills = { paths = vim.fn.expand('%') } })<CR>";
            desc = "Open find and replace on the current buffer";
          }
          {
            key = "<leader>gR";
            mode = ["n"];
            action = "<cmd>lua require('grug-far').open({ transient = true })<CR>";
            desc = "Open find and replace globally";
          }
          {
            key = "<leader>gr";
            mode = ["x"];
            action = "<cmd>lua require('grug-far').with_visual_selection({ transient = true, prefills = { paths = vim.fn.expand('%') } })<CR>";
            desc = "Open find and replace with visual selection";
          }
          {
            key = "<leader>e";
            mode = ["n"];
            action = "<cmd>Neotree toggle<CR>";
            desc = "Toggle Neotree";
          }
          {
            key = "<S-h>";
            mode = ["n"];
            action = "<cmd>BufferLineCyclePrev<CR>";
            desc = "Previous buffer";
          }
          {
            key = "<S-l>";
            mode = ["n"];
            action = "<cmd>BufferLineCycleNext<CR>";
            desc = "Next buffer";
          }
          {
            key = "<leader>bd";
            mode = ["n"];
            action = "<cmd>bdelete<CR>";
            desc = "Close buffer";
          }
        ];
        augroups = [{name = "ForceConformKey";}];
        autocmds = [
          {
            event = ["LspAttach"];
            group = "ForceConformKey";
            desc = "Force the use of conform-nvim for formatting";
            callback = lib.generators.mkLuaInline ''
              function(ev)
                vim.keymap.set("n", "<leader>lf", function()
                   require("conform").format({ async = true, lsp_fallback = true })
                end, { buffer = ev.buf, desc = "Format buffer (Conform)", silent = true })
              end
            '';
          }
        ];

        lsp = {
          enable = true;

          formatOnSave = true;
          lightbulb.enable = true;
          otter-nvim.enable = true;
          trouble.enable = true;
          nvim-docs-view.enable = true;
          presets.harper.enable = true;
        };

        debugger = {
          nvim-dap = {
            enable = true;
            ui.enable = true;
          };
        };

        languages = {
          enableFormat = true;
          enableTreesitter = true;
          enableExtraDiagnostics = true;

          nix.enable = true;
          markdown.enable = true;
          bash.enable = true;
        };

        visuals = {
          nvim-scrollbar.enable = true;
          nvim-web-devicons.enable = true;
          nvim-cursorline.enable = true;
          cinnamon-nvim = {
            enable = true;
            setupOpts = {
              keymaps = {
                basic = true;
                extra = true;
              };
              options = {
                max_delta = {
                  line = false;
                  time = 5000;
                };
                step_size = {
                  vertical = 2;
                };
              };
            };
          };
          fidget-nvim.enable = true;

          highlight-undo.enable = true;
          blink-indent.enable = true;
          indent-blankline.enable = true;
        };

        statusline = {
          lualine = {
            enable = true;
            theme = "ayu_dark";
          };
        };

        autopairs.nvim-autopairs.enable = true;

        autocomplete = {
          blink-cmp = {
            enable = true;
            mappings = {
              previous = "<C-w>";
              next = "<C-s>";
            };
          };
        };

        snippets.luasnip.enable = true;
        filetree = {
          neo-tree = {
            enable = true;
            setupOpts = {
              window.mappings = {
                "l" = "open";
                "h" = "close_node";
              };
              event_handlers = [
                {
                  event = "file_opened";
                  handler = lib.generators.mkLuaInline ''
                    function()
                      require("neo-tree.command").execute({ action = "close" })
                    end
                  '';
                }
              ];
            };
          };
        };
        tabline = {
          nvimBufferline.enable = true;
        };
        treesitter.context.enable = true;
        binds = {
          whichKey.enable = true;
        };
        telescope = {
          enable = true;
          mappings = {
            lspDocumentSymbols = "<leader>fds";
          };
          setupOpts = {
            defaults.mappings = {
              i = {
                "<C-w>" = lib.generators.mkLuaInline "require('telescope.actions').move_selection_previous";
                "<C-s>" = lib.generators.mkLuaInline "require('telescope.actions').move_selection_next";
              };
              n = {
                "<C-w>" = lib.generators.mkLuaInline "require('telescope.actions').move_selection_previous";
                "<C-s>" = lib.generators.mkLuaInline "require('telescope.actions').move_selection_next";
              };
            };
          };
        };
        git = {
          enable = true;
          gitsigns.enable = true;
          gitsigns.codeActions.enable = false;
          neogit.enable = true;
        };
        dashboard = {
          alpha.enable = true;
        };
        notify = {
          nvim-notify.enable = true;
        };
        utility = {
          diffview-nvim.enable = true;
          icon-picker.enable = true;
          surround.enable = true;
          smart-splits.enable = true;
          undotree.enable = true;
          nvim-biscuits.enable = true;
          grug-far-nvim.enable = true;
          motion = {
            hop.enable = true;
            leap.enable = true;
          };
          images = {
            img-clip.enable = true;
          };
        };
        terminal = {
          toggleterm = {
            enable = true;
            lazygit.enable = true;
          };
        };
        ui = {
          borders.enable = true;
          noice.enable = true;
          colorizer.enable = true;
          illuminate.enable = true;
          breadcrumbs = {
            enable = true;
            navbuddy.enable = true;
          };
          smartcolumn = {
            enable = true;
          };
          fastaction.enable = true;
        };
        comments = {
          comment-nvim.enable = true;
        };
      };
    };
  };
}
