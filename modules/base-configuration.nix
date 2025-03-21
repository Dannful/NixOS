{ lib, config, pkgs, inputs, ... }:

let
  inherit (lib) mkOption types;
  cfg = config.base-config;
  aagl-gtk-on-nix = import (builtins.fetchTarball {
    url = "https://github.com/ezKEa/aagl-gtk-on-nix/archive/main.tar.gz";
    sha256 = "0z9lg60k9f58asx6myz25ysp3finfa8yrzz6ars2lasi5zhvg4s9";
  });
in {
  imports = [ aagl-gtk-on-nix.module ];
  options.base-config = {
    users = mkOption {
      type = types.listOf (types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            description = "User name";
            example = "default";
          };
          password = mkOption {
            type = types.str;
            description = "User password in SHA512 hash";
            example =
              "$6$l8tWRCtkcDiV17p4$zsEIc9/vY62pR2kFhUnO9R/hWdGDTQyMIKREVpNUSZl6cFeUDNz3/9dK.CeQ2vwBk45pEeNKT7T9rb4d1pLLn/";
          };
          groups = mkOption {
            type = types.listOf types.str;
            description = "Extra groups for the user";
            example = "[]";
            default = [ ];
          };
          home-file-path = mkOption {
            type = types.path;
            description = "Home nix file path";
            example = "./home.nix";
          };
        };
      });
    };
    use-nvidia = mkOption {
      type = types.bool;
      default = false;
      description = "Whether or not NVIDIA should be used";
    };
    use-steam = mkOption {
      type = types.bool;
      default = false;
      description = "Whether or not Steam should be installed";
    };
  };
  config = {
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "nixos";
    # networking.wireless.enable = true;

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Enable networking
    networking.networkmanager.enable = true;

    # Set your time zone.
    time.timeZone = "America/Sao_Paulo";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_US.UTF-8";

    i18n.extraLocaleSettings = {
      LC_ADDRESS = "pt_BR.UTF-8";
      LC_IDENTIFICATION = "pt_BR.UTF-8";
      LC_MEASUREMENT = "pt_BR.UTF-8";
      LC_MONETARY = "pt_BR.UTF-8";
      LC_NAME = "pt_BR.UTF-8";
      LC_NUMERIC = "pt_BR.UTF-8";
      LC_PAPER = "pt_BR.UTF-8";
      LC_TELEPHONE = "pt_BR.UTF-8";
      LC_TIME = "pt_BR.UTF-8";
    };

    # Enable the X11 windowing system.
    services.xserver = {
      enable = true;
      displayManager.gdm = {
        enable = true;
        wayland = true;
      };
    };
    services.gvfs.enable = true;
    nixpkgs.overlays = [
      (self: super: {
        gnome = super.gnome.overrideScope' (gself: gsuper: {
          nautilus = gsuper.nautilus.overrideAttrs (nsuper: {
            buildInputs = nsuper.buildInputs
              ++ (with pkgs.gst_all_1; [ gst-plugins-good gst-plugins-bad ]);
          });
        });
      })
    ];
    xdg.portal.enable = true;
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
      package = inputs.hyprland.packages."${pkgs.system}".hyprland;
    };

    # Configure keymap in X11
    services.xserver.xkb = {
      layout = "us";
      variant = "alt-intl";
    };

    # Configure console keymap
    console.keyMap = "dvorak";

    # Enable CUPS to print documents.
    services.printing.enable = true;

    # Enable sound with pipewire.
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };

    # Enable touchpad support (enabled default in most desktopManager).
    # services.xserver.libinput.enable = true;

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users = builtins.listToAttrs (builtins.map (user: {
      name = user.name;
      value = {
        hashedPassword = user.password;
        isNormalUser = true;
        description = user.name;
        extraGroups = [ "networkManager" "wheel" "docker" ] ++ user.groups;
        packages = [ ];
        shell = pkgs.zsh;
      };
    }) cfg.users);
    programs.zsh.enable = true;

    home-manager = {
      extraSpecialArgs = { inherit inputs; };
      users = builtins.listToAttrs (builtins.map (user: {
        name = user.name;
        value = import user.home-file-path;
      }) cfg.users);
      backupFileExtension = "backup";
    };

    # Install firefox.
    programs.firefox.enable = true;

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs;
      [
        vim
        home-manager
        ffmpeg
        nixd
        nixfmt-classic
        nautilus
        webcord-vencord
        youtube-music
        pavucontrol
      ] ++ lib.optionals cfg.use-steam [
        pkgs.protonup
        pkgs.mangohud
        pkgs.lutris
      ];

    programs.anime-game-launcher.enable = cfg.use-steam;

    nix.settings = {
      substituters = [ "https://ezkea.cachix.org" ];
      trusted-public-keys =
        [ "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI=" ];
    };

    virtualisation.docker.enable = true;

    fonts.packages = with pkgs; [
      (nerdfonts.override { fonts = [ "FiraCode" ]; })
      iosevka
      hack-font
    ];
    fonts = {
      fontconfig = {
        defaultFonts = {
          serif = [ "FiraCode Nerd Font" ];
          sansSerif = [ "FiraCode Nerd Font" ];
          monospace = [ "FiraCode Nerd Font Mono" ];
        };
      };
    };

    environment.sessionVariables = {
      WLR_NO_HARDWARE_CURSORS = "1";
      NIXOS_OZONE_WL = "1";
    };

    system.stateVersion = "24.05"; # Did you read the comment?

    programs.steam = lib.mkIf cfg.use-steam {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      gamescopeSession.enable = true;
    };
    programs.gamemode.enable = lib.mkIf cfg.use-steam true;
    services.xserver.videoDrivers = lib.mkIf cfg.use-nvidia [ "nvidia" ];
    hardware.nvidia = lib.mkIf cfg.use-nvidia {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
    hardware.graphics = { enable = true; };

    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;

    services.blueman.enable = true;

    system.autoUpgrade.enable = true;
    system.autoUpgrade.dates = "weekly";

    nix.gc.automatic = true;
    nix.gc.dates = "daily";
    nix.gc.options = "--delete-older-than 3d";
    nix.settings.auto-optimise-store = true;

    system.autoUpgrade.channel = "https://nixos.org/channels/nixos-unstable";
  };
}
