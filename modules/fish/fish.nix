{ pkgs, ... }:

{
  home.packages = [ pkgs.any-nix-shell pkgs.fd pkgs.fzf pkgs.bat ];
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  programs.fish = {
    enable = true;
    plugins = [
      {
        name = "tide";
        src = pkgs.fishPlugins.tide.src;
      }
      {
        name = "autopair";
        src = pkgs.fishPlugins.autopair.src;
      }
      {
        name = "fzf-fish";
        src = pkgs.fishPlugins.fzf-fish.src;
      }
      {
        name = "pufferfish";
        src = pkgs.fishPlugins.puffer.src;
      }
    ];

    interactiveShellInit = ''
      set -g fish_greeting
      eval "$(direnv hook fish)"

      if not set -q tide_git_icon
        tide configure --auto --style=Rainbow --prompt_colors="16 colors" --show_time="24-hour format" --rainbow_prompt_separators=Angled --powerline_prompt_heads=Round --powerline_prompt_tails=Round --powerline_prompt_style="Two lines, character and frame" --prompt_connection=Dotted --powerline_right_prompt_frame=Yes --prompt_spacing=Sparse --icons="Many icons" --transient=Yes
      end
    '';
  };
}
