{ config, pkgs, inputs, ... }:

let
  startupScript = pkgs.pkgs.writeShellScriptBin "start" ''
    ${pkgs.eww}/bin/eww open left_bar
    ${pkgs.eww}/bin/eww open bottom_bar
    
    ${pkgs.swww}/bin/swww init &
    sleep 1
    ${pkgs.swww}/bin/swww img ${configs/wallpapers/ai.png} -o "DP-1" &
    ${pkgs.swww}/bin/swww img ${configs/wallpapers/overlord.png} -o "HDMI-A-1" &
  '';
in
{
  imports = [ ./configs/main.nix ../modules/zsh/zsh.nix ];
  home.username = "dannly";
  home.homeDirectory = "/home/dannly";

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  home.stateVersion = "24.05"; # Please read the comment before changing.

  home.packages = [
    pkgs.feh
    pkgs.gh
    pkgs.lazygit
    pkgs.discord-ptb
    pkgs.eww
    pkgs.swww
    pkgs.playerctl
    pkgs.pamixer
    pkgs.alsa-utils
  ];

  home.file."Pictures/wallpapers" = {
    source = ./configs/wallpapers;
    recursive = true;
  };

  home.file.".config/eww" = {
    source = ../modules/eww;
    recursive = true;
  };

  home.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
  };

  programs.home-manager = {
    enable = true;
  };

  services.mako = {
    enable = true;
    anchor = "top-right";
    font = "FiraCode Nerd Font 12";
  };

  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;

    plugins = [
      inputs.hyprland-plugins.packages."${pkgs.system}".borders-plus-plus
    ];

    settings = {
      "$mod" = "SUPER";
      "$alt" = "ALT";
      general = {
        gaps_out = "18, 18, 60, 60";
      };
      input = {
        kb_layout = "us";
        kb_variant = "alt-intl";
      };
      exec-once = ''${startupScript}/bin/start'';
      monitor = [
        "DP-1, 1920x1080@165.00, 0x0, 1"
        "HDMI-A-1, 1920x1200@59.95, 1920x0, 1" 
      ];
      bind = [
        "$alt, B, exec, ${pkgs.firefox}/bin/firefox"
        "$alt, D, exec, ${pkgs.discord}/bin/discord"
        "$mod, Return, exec, ${pkgs.kitty}/bin/kitty"
        "$mod, D, exec, ${pkgs.rofi-wayland}/bin/rofi -dmenu"
	"$mod, R, exec, hyprctl reload"
        "$mod, Q, exec, hyprctl kill"
	"$mod, Print, exec, flameshot gui -c"
      ]
      ++ (
        builtins.concatLists(builtins.genList (i:
          let ws = i + 1;
          in [
            "$mod, code:1${toString i}, workspace, ${toString ws}"
            "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
          ]
        )
        9)
      );
      "plugin:borders-plus-plus" = {
        add_borders = 1;
        
        "col.border_1" = "rgb(ffffff)";
        "col.border_2" = "rgb(2222ff)";

        border_size_1 = 6;
        border_size_2 = 3;

        natural_rounding = "yes";
      };
    };
  };
}
