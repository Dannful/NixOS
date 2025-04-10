{ pkgs, lib, ... }:

{
  home.packages = [ pkgs.any-nix-shell pkgs.direnv ];
  programs.fish = {
    enable = true;
    plugins = [{
      name = "tide";
      src = pkgs.fishPlugins.tide.src;
    }];

    interactiveShellInit = ''
      set fish_greeting
      eval "$(direnv hook fish)"
    '';
  };
  home.activation.configure-tide = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${pkgs.fish}/bin/fish -c "tide configure --auto --style=Rainbow --prompt_colors='16 colors' --show_time='24-hour format' --rainbow_prompt_separators=Angled --powerline_prompt_heads=Round --powerline_prompt_tails=Round --powerline_prompt_style='Two lines, character and frame' --prompt_connection=Dotted --powerline_right_prompt_frame=Yes --prompt_spacing=Sparse --icons='Many icons' --transient=Yes"
  '';
}
