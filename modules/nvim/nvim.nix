{
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [inputs.nvf.homeManagerModules.default];

  home.packages = [
    pkgs.ripgrep
    pkgs.fd
    pkgs.neovide
  ];

  xdg.configFile."neovide/config.toml".text = ''
    [window]
    maximize = false
    remember-window-size = true
  '';

  home.shellAliases = {
    neovide = "neovide --fork";
    nvim = "neovide";
    vim = "neovide";
    vi = "neovide";
  };

  programs.nvf = {
    enable = true;
    settings = {
      vim = {
        globals = {
          neovide_opacity = 0.9;
          neovide_floating_blur_amount_x = 2.0;
          neovide_floating_blur_amount_y = 2.0;
          neovide_remember_window_size = true;
          neovide_cursor_vfx_mode = "railgun";
        };

        options = {
          guifont = "FiraCode Nerd Font:h12";
        };
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
        luaConfigRC = {
          neovide_font = ''
            if vim.g.neovide then
              vim.o.guifont = "FiraCode Nerd Font:h12"
            end
          '';
          language_selector = ''
            _G.open_language_selector = function()
              local parsers = require("nvim-treesitter.parsers").get_parser_configs()
              local languages = {}

              for lang, _ in pairs(parsers) do
                table.insert(languages, lang)
              end

              table.sort(languages)

              vim.ui.select(languages, {
                prompt = "Select Language (Filetype):",
                format_item = function(item)
                  return "📝 " .. item
                end,
              }, function(choice)
                if choice then
                  vim.bo.filetype = choice
                  print("Set filetype to: " .. choice)
                end
              end)
            end
          '';
        };
        keymaps = [
          {
            key = "g.";
            mode = [
              "n"
              "v"
            ];
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
            mode = [
              "n"
              "t"
            ];
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
            key = "gs";
            mode = ["n"];
            action = "<cmd>lua Snacks.picker.lsp_symbols()<CR>";
            desc = "LSP Symbols";
          }
          {
            key = "gS";
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
            key = "<leader>sD";
            mode = ["n"];
            action = "<cmd>lua Snacks.picker.diagnostics()<CR>";
            desc = "LSP Diagnostics";
          }
          {
            key = "<leader>sd";
            mode = ["n"];
            action = "<cmd>lua Snacks.picker.diagnostics_buffer()<CR>";
            desc = "LSP Buffer Diagnostics";
          }
          {
            key = "<leader>gi";
            mode = ["n"];
            action = "<cmd>lua Snacks.picker.gh_issue()<CR>";
            desc = "GitHub Issues (open)";
          }
          {
            key = "<leader>gp";
            mode = ["n"];
            action = "<cmd>lua Snacks.picker.gh_pr()<CR>";
            desc = "GitHub Pull Requests (open)";
          }
          {
            key = "<leader>lm";
            mode = "n";
            desc = "Select Buffer Language";
            action = ":lua _G.open_language_selector()<CR>";
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
          inlayHints.enable = true;
          lightbulb.enable = true;
          trouble.enable = true;
          otter-nvim.enable = true;
          nvim-docs-view.enable = true;
        };

        formatter.conform-nvim = {
          enable = true;
          setupOpts = {
            format_on_save = {
              lsp_fallback = true;
              timeout_ms = 500;
            };
            notify_on_error = true;
          };
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
          bash.enable = true;
          yaml.enable = true;
          json.enable = true;
          markdown = {
            enable = true;
            extensions.markview-nvim.enable = true;
          };
        };
        git.gitsigns = {
          enable = true;
          setupOpts = {
            current_line_blame = true;
          };
        };
        utility = {
          direnv.enable = true;
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
              statuscolumn.enabled = true;
              words.enabled = true;
              bufdelete.enabled = true;
              gitsigns.enabled = true;
              gh.enabled = true;
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
              "core.concealer" = {
                config = {
                  icon_preset = "diamond";
                };
              };
              "core.esupports.metagen" = {
                config = {
                  type = "auto";
                  update_date = true;
                };
              };
              "core.qol.toc" = {};
              "core.qol.todo_items" = {};
              "core.looking-glass" = {};
              "core.presenter" = {
                config = {
                  zen_mode = "zen-mode";
                };
              };
              "core.export" = {};
              "core.export.markdown" = {
                config = {
                  extensions = "all";
                };
              };
              "core.summary" = {};
              "core.tangle" = {
                config = {
                  report_on_empty = false;
                };
              };
              "core.ui.calendar" = {};
            };
          };
        };
      };
    };
  };
}
