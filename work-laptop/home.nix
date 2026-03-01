{pkgs, ...}: {
  imports = [
    ../modules/kitty/custom-kitty.nix
    ../modules/hyprland/custom-hyprland.nix
    ../modules/git/git.nix
    ../modules/emacs/emacs.nix
    ../modules/nvim/nvim.nix
  ];
  home = {
    username = "vinidan";
    homeDirectory = "/home/vinidan";

    stateVersion = "24.05";

    file.".ssh/config" = {
      text = ''
        Host github.com
          Hostname ssh.github.com
          Port 443
          User git
      '';
    };

    packages = with pkgs; [
      gh
      lazygit
      bruno
      brightnessctl
      jetbrains.datagrip
      gemini-cli
    ];
  };

  nixpkgs = {config = {allowUnfree = true;};};

  custom-kitty = {enable = true;};

  services.batsignal = {
    enable = true;
    extraArgs = [
      "-w"
      "30"
      "-c"
      "15"
      "-d"
      "10"
      "-m"
      "Battery low"
    ];
  };
  programs = {
    home-manager.enable = true;
    nvf.settings.vim = {
      languages = {
        ruby.enable = true;
      };
    };
  };

  custom-hyprland = {
    enable = true;
    monitors = [
      {
        name = "HDMI-A-1";
        resolution = "2560x1080";
        refresh-rate = "59.98";
        position = "0x0";
      }
      {
        name = "eDP-1";
        resolution = "1920x1080";
        refresh-rate = "60.00";
        position = "2560x0";
      }
    ];
  };
}
