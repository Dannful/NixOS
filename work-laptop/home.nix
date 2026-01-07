{pkgs, ...}: {
  imports = [
    ../modules/kitty/custom-kitty.nix
    ../modules/zed/zed.nix
    ../modules/hyprland/custom-hyprland.nix
    ../modules/git/git.nix
    ../modules/emacs/emacs.nix
    ../modules/nvim/nvim.nix
  ];
  home.username = "vinidan";
  home.homeDirectory = "/home/vinidan";

  home.stateVersion = "24.05";

  nixpkgs = {config = {allowUnfree = true;};};

  home.file.".ssh/config" = {
    text = ''
      Host github.com
        Hostname ssh.github.com
        Port 443
        User git
    '';
  };

  home.packages = with pkgs; [
    gh
    lazygit
    awscli2
    bruno
    brightnessctl
    nomad
    jetbrains.datagrip
    gemini-cli
  ];

  home.sessionVariables = {NOMAD_ADDR = "http://52.67.92.147:4646";};

  programs.home-manager.enable = true;

  custom-kitty = {enable = true;};

  custom-zed = {
    enable = true;
    lsp = {
      omnisharp = {
        path = "${pkgs.omnisharp-roslyn}/bin/OmniSharp";
        arguments = ["-lsp"];
      };
    };
  };

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

  programs.nvf.settings.vim.languages.csharp.enable = true;

  custom-hyprland = {
    enable = true;
    monitors = [
      {
        name = "HDMI-A-1";
        resolution = "3440x1440";
        refresh-rate = "84.96";
        position = "0x0";
      }
      {
        name = "eDP-1";
        resolution = "1920x1080";
        refresh-rate = "60.00";
        position = "3440x0";
      }
    ];
  };
}
