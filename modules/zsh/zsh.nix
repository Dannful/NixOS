{ config, pkgs, ... }:

{
  home.file.".zshrc" = {
    source = ./.zshrc;
  };
  home.file.".oh-my-zsh" = {
    source = ./.oh-my-zsh;
    recursive = true;
  };
}
