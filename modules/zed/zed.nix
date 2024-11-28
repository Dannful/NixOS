{ pkgs, ... }:

{
  home.file.".config/zed/tasks.json" = {
    source = ./tasks.json;
  };
  home.file.".config/zed/keymap.json" = {
    source = ./keymap.json;
  };
  programs.zed-editor = {
    enable = true;
    
    userSettings = {
      vim_mode = true;
      ui_font_size = 15;
      ui_font_family = "JetBrains Mono Nerd Font";
      buffer_font_size = 15;
      buffer_font_family = "JetBrains Mono Nerd Font";
      autosave = "on_focus_change";
      relative_line_numbers = true;
      theme = "Sandcastle";
      indent_guides = {
        enabled = true;
        active_line_width = 3;
      };
      show_whitespaces = "boundary";
    };
  };
}
