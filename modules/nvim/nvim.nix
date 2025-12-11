{
  pkgs,
  inputs,
  ...
}: let
  customRPackages = [
    pkgs.rPackages.tidyverse
    pkgs.rPackages.janitor
    pkgs.rPackages.here
    pkgs.rPackages.DoE_base
    pkgs.rPackages.ggh4x
    pkgs.rPackages.plotly
  ];
in {
  imports = [inputs.nvf.homeManagerModules.default];

  home.packages = [
    (pkgs.rWrapper.override
      {
        packages = customRPackages;
      })
    pkgs.visidata
    pkgs.ripgrep
    pkgs.fd
  ];

  programs.nvf = {
    enable = true;
    settings = {
      vim = {
        viAlias = true;
        vimAlias = true;

        luaConfigRC.r_iron_keymaps = ''
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
        luaConfigRC.r_view = ''
        '';
        keymaps = [
          {
            key = "g.";
            mode = ["n" "v"];
            action = "<cmd>lua require(\"fastaction\").code_action()<CR>";
            silent = true;
          }
          {
            key = "<leader><space>";
            mode = ["n"];
            action = "<cmd>lua Snacks.picker.smart()<CR>";
            desc = "Smart Find Files";
          }
          {
            key = "<leader>,";
            mode = ["n"];
            action = "<cmd>lua Snacks.picker.buffers()<CR>";
            desc = "Buffers";
          }
          {
            key = "<leader>/";
            mode = ["n"];
            action = "<cmd>lua Snacks.picker.grep()<CR>";
            desc = "Grep";
          }
          {
            key = "<leader>:";
            mode = ["n"];
            action = "<cmd>lua Snacks.picker.command_history()<CR>";
            desc = "Command History";
          }
          {
            key = "<leader>n";
            mode = ["n"];
            action = "<cmd>lua Snacks.picker.notifications()<CR>";
            desc = "Notification History";
          }
          {
            key = "<leader>e";
            mode = ["n"];
            action = "<cmd>lua Snacks.explorer()<CR>";
            desc = "File Explorer";
          }
          {
            key = "<leader>fb";
            mode = ["n"];
            action = "<cmd>lua Snacks.picker.buffers()<CR>";
            desc = "Buffers";
          }
          {
            key = "<leader>ff";
            mode = ["n"];
            action = "<cmd>lua Snacks.picker.files()<CR>";
            desc = "Find Files";
          }
          {
            key = "<leader>fg";
            mode = ["n"];
            action = "<cmd>lua Snacks.picker.git_files()<CR>";
            desc = "Find Git Files";
          }
          {
            key = "<leader>fr";
            mode = ["n"];
            action = "<cmd>lua Snacks.picker.recent()<CR>";
            desc = "Recent";
          }
          {
            key = "<leader>gl";
            mode = ["n"];
            action = "<cmd>lua Snacks.picker.git_log()<CR>";
            desc = "Git Log";
          }
          {
            key = "<leader>gd";
            mode = ["n"];
            action = "<cmd>lua Snacks.picker.git_diff()<CR>";
            desc = "Git Diff (Hunks)";
          }
          {
            key = "<leader>z";
            mode = ["n"];
            action = "<cmd>lua Snacks.zen()<CR>";
            desc = "Toggle Zen Mode";
          }
          {
            key = "<leader>Z";
            mode = ["n"];
            action = "<cmd>lua Snacks.zen.zoom()<CR>";
            desc = "Toggle Zoom";
          }
          {
            key = "<leader>.";
            mode = ["n"];
            action = "<cmd>lua Snacks.scratch()<CR>";
            desc = "Toggle Scratch Buffer";
          }
          {
            key = "<leader>S";
            mode = ["n"];
            action = "<cmd>lua Snacks.scratch.select()<CR>";
            desc = "Select Scratch Buffer";
          }
          {
            key = "<leader>bd";
            mode = ["n"];
            action = "<cmd>lua Snacks.bufdelete()<CR>";
            desc = "Delete Buffer";
          }
          {
            key = "<leader>cR";
            mode = ["n"];
            action = "<cmd>lua Snacks.rename.rename_file()<CR>";
            desc = "Rename File";
          }
          {
            key = "<leader>gB";
            mode = ["n"];
            action = "<cmd>lua Snacks.gitbrowse()<CR>";
            desc = "Git Browse";
          }
          {
            key = "<leader>gg";
            mode = ["n"];
            action = "<cmd>lua Snacks.lazygit()<CR>";
            desc = "Lazygit";
          }
          {
            key = "<leader>un";
            mode = ["n"];
            action = "<cmd>lua Snacks.notifier.hide()<CR>";
            desc = "Dismiss All Notifications";
          }
          {
            key = "<c-/>";
            mode = ["n" "t"];
            action = "<cmd>lua Snacks.terminal()<CR>";
            desc = "Toggle Terminal";
          }
          {
            key = "gd";
            mode = ["n"];
            action = "<cmd>lua Snacks.picker.lsp_definitions()<CR>";
            desc = "Goto Definition";
          }
          {
            key = "gD";
            mode = ["n"];
            action = "<cmd>lua Snacks.picker.lsp_declarations()<CR>";
            desc = "Goto Declaration";
          }
          {
            key = "gr";
            mode = ["n"];
            action = "<cmd>lua Snacks.picker.lsp_references()<CR>";
            desc = "References";
          }
          {
            key = "gI";
            mode = ["n"];
            action = "<cmd>lua Snacks.picker.lsp_implementations()<CR>";
            desc = "Goto Implementation";
          }
          {
            key = "gy";
            mode = ["n"];
            action = "<cmd>lua Snacks.picker.lsp_type_definitions()<CR>";
            desc = "Goto T[y]pe Definition";
          }
          {
            key = "<leader>ss";
            mode = ["n"];
            action = "<cmd>lua Snacks.picker.lsp_symbols()<CR>";
            desc = "LSP Symbols";
          }
          {
            key = "<leader>sS";
            mode = ["n"];
            action = "<cmd>lua Snacks.picker.lsp_workspace_symbols()<CR>";
            desc = "LSP Workspace Symbols";
          }
          {
            key = "gn";
            mode = ["n"];
            action = "<cmd>lua vim.lsp.buf.rename()<CR>";
            desc = "LSP Rename Symbol";
          }
          {
            key = "<leader>sd";
            mode = ["n"];
            action = "<cmd>lua Snacks.picker.diagnostics()<CR>";
            desc = "LSP Diagnostics";
          }
          {
            key = "<leader>sD";
            mode = ["n"];
            action = "<cmd>lua Snacks.picker.diagnostics_buffer()<CR>";
            desc = "LSP Buffer Diagnostics";
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

        treesitter = {
          context.enable = true;
          fold = true;
        };

        lsp = {
          enable = true;
          formatOnSave = true;
          inlayHints.enable = true;
          lightbulb.enable = true;
          trouble.enable = true;
          otter-nvim.enable = true;
          nvim-docs-view.enable = true;
        };

        binds = {
          whichKey.enable = true;
          cheatsheet.enable = true;
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
          r = let
            r-with-languageserver = pkgs.rWrapper.override {
              packages = [pkgs.rPackages.languageserver] ++ customRPackages;
            };
          in {
            enable = true;
            lsp.package = pkgs.writeShellScriptBin "r_lsp" ''
              ${r-with-languageserver}/bin/R --slave -e "languageserver::run()"
            '';
          };
          css = {
            enable = true;
            format.type = "biome";
          };
          yaml.enable = true;
          markdown = {
            enable = true;
            extensions.markview-nvim.enable = true;
          };
          java.enable = true;
        };
        formatter.conform-nvim = {
          setupOpts.formatters_by_ft = {
            javascript = [
              "biome"
            ];
          };
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
          nvim-biscuits.enable = true;
          snacks-nvim = {
            enable = true;
            setupOpts = {
              bigfile.enabled = true;
              explorer.enabled = true;
              indent.enabled = true;
              input.enabled = true;
              notifier.enabled = true;
              picker.enabled = true;
              quickfile.enabled = true;
              scope.enabled = true;
              scroll.enabled = true;
              statuscolumn.enabled = true;
              words.enabled = true;
              zen.enabled = true;
              bufdelete.enabled = true;
              gitsigns.enabled = true;
              image.enabled = true;
            };
          };
        };
        ui = {
          noice.enable = true;
          borders.enable = true;
          colorizer.enable = true;
          fastaction.enable = true;
          breadcrumbs = {
            enable = true;
            navbuddy.enable = true;
          };
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
          "iron.nvim" = {
            package = pkgs.vimPlugins.iron-nvim;
            setupModule = "iron.core";
            setupOpts = {
              config = {
                scratch_repl = true; # Wipe REPL history on close
                repl_definition = {
                  r = {
                    command = ["R"]; # Command to launch R
                  };
                };
                repl_open_cmd = "vertical botright 40 split";
              };
              keymaps = {}; # Handled manually in luaConfigRC
              highlight = {
                italic = true;
              };
            };
          };
        };

        visuals = {
          fidget-nvim.enable = true;
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
