{ pkgs, lib, config, ... }:
let
  inherit (lib) mkOption types;
  cfg = config.custom-zed;
in {
  options.custom-zed = {
    enable = lib.mkEnableOption "custom zed";
    lsp = mkOption {
      type = types.raw;
      description = "LSP configuration";
      default = { };
      example = {
        omnisharp = {
          path = "${pkgs.omnisharp-roslyn}/bin/OmniSharp";
          arguments = [ "-lsp" ];
        };
      };
    };
  };
  config = lib.mkIf cfg.enable {
    home.file.".config/zed/tasks.json" = { source = ./tasks.json; };
    home.file.".config/zed/keymap.json" = { source = ./keymap.json; };
    programs.zed-editor = {
      enable = true;

      userSettings = {
        vim_mode = true;
        ui_font_size = 15;
        ui_font_family = "FiraCode Nerd Font";
        buffer_font_size = 15;
        buffer_font_family = "FiraCode Nerd Font";
        autosave = "on_focus_change";
        relative_line_numbers = true;
        theme = {
          mode = "dark";
          light = "Ayu Light";
          dark = "One Dark";
        };
        indent_guides = {
          enabled = true;
          active_line_width = 3;
        };
        show_whitespaces = "boundary";
        tab_size = 2;
        lsp = let
          formatter = {
            initialization_options = {
              formatting = { command = [ "nixfmt" "--quiet" "--" ]; };
            };
          };
        in cfg.lsp // {
          nil = formatter;
          nixd = formatter;
          rust-analyzer = {
            initialization_options = { check.command = "clippy"; };
          };
          eslint = {
            settings = { nodePath = "${pkgs.nodePackages.nodejs}/bin/node"; };
          };
        };
        languages = {
          Javascript = {
            formatter = {
              external = {
                command = "${pkgs.prettierd}";
                arguments = [ "--stdin-filepath" "{buffer_path}" ];
              };
            };
          };
        };
        project_panel = { auto_fold_dirs = false; };
        terminal = { shell = { program = "zsh"; }; };
        base_keymap = "Atom";
        diagnostics = {
          include_warnings = true;
          inline = { enabled = true; };
        };
        agent = {
          default_model = {
            provider = "copilot_chat";
            model = "gpt-4o";
          };
        };
        features = { edit_prediction_provider = "copilot"; };
      };
    };
  };
}
