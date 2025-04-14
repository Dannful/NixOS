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
          mode = "system";
          light = "Ayu Light";
          dark = "Ayu Mirage";
        };
        indent_guides = {
          enabled = true;
          active_line_width = 3;
        };
        show_whitespaces = "boundary";
        tab_size = 2;
        lsp = cfg.lsp;
        project_panel = { auto_fold_dirs = false; };
        terminal = { shell = { program = "fish"; }; };
      };
    };
  };
}
