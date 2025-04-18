{ lib, config, pkgs, inputs, ... }:
let
  inherit (lib) mkOption types;
  cfg = config.base-config;
  aagl-gtk-on-nix = import (builtins.fetchTarball {
    url = "https://github.com/ezKEa/aagl-gtk-on-nix/archive/main.tar.gz";
    sha256 = "118845yyl8z7imvx8z4sarx1vlw9sws0wmhsakl8zkrm8ls900wm";
  });
  pkgs-unstable =
    inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};

  custom-sddm-astronaut = pkgs.sddm-astronaut.override {
    themeConfig = {
      Background = if (cfg.login-wallpaper != null) then
        (toString cfg.login-wallpaper)
      else
        "${pkgs.fetchurl {
          url =
            "https://raw.githubusercontent.com/Keyitdev/sddm-astronaut-theme/refs/heads/master/Backgrounds/pixel_sakura.gif";
          hash = "sha256-wqfnUspZY9UlCuCKSum49/HHz3A9vndNc7caspvL+7M=";
        }}";
    };
    embeddedTheme = "astronaut";
  };
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
    login-wallpaper = mkOption {
      type = types.nullOr types.path;
      description = "Path to the image";
      default = null;
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
    services.xserver.enable = true;
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      package = pkgs.kdePackages.sddm;
      theme = "sddm-astronaut-theme";
      extraPackages = [ custom-sddm-astronaut ];
    };
    services.gvfs.enable = true;
    nixpkgs.overlays = [
      (self: super: {
        gnome = super.gnome.overrideScope (gself: gsuper: {
          nautilus = gsuper.nautilus.overrideAttrs (nsuper: {
            buildInputs = nsuper.buildInputs
              ++ (with pkgs.gst_all_1; [ gst-plugins-good gst-plugins-bad ]);
          });
        });
      })
    ];
    xdg.portal.enable = true;
    programs.hyprland = {
      enable = true;
      package =
        inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      portalPackage =
        inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    };

    # Configure keymap in X11
    services.xserver.xkb = {
      layout = "us";
      variant = "alt-intl";
    };

    console.useXkbConfig = true;

    # Enable CUPS to print documents.
    services.printing.enable = true;

    # Enable sound with pipewire.
    services.pulseaudio.enable = false;
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
        shell = pkgs.bash;
      };
    }) cfg.users);

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

    # Enable Fish
    programs.fish.enable = true;

    # Disable command not found for flakes
    programs.command-not-found.enable = false;

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs;
      [
        # Home manager
        home-manager

        # Text editors
        vim

        # LSP
        nixd
        nil

        # Formatters
        nixfmt-classic

        # Theming
        custom-sddm-astronaut
        qt5.qtquickcontrols2
        qt5.qtgraphicaleffects

        # Media
        discord
        youtube-music
        zathura

        # Utilities
        ffmpeg
        pavucontrol

        # Terminal
        kitty

        # File manager
        nautilus
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

    fonts.packages = with pkgs; [ nerd-fonts.fira-code iosevka hack-font ];
    fonts = {
      fontconfig = {
        defaultFonts = {
          serif = [ "FiraCode Nerd Font" ];
          sansSerif = [ "FiraCode Nerd Font" ];
          monospace = [ "FiraCode Nerd Font Mono" ];
        };
      };
    };

    environment.sessionVariables = { NIXOS_OZONE_WL = "1"; };

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
    hardware.graphics = {
      enable = true;
      package = pkgs-unstable.mesa;
      enable32Bit = true;
      package32 = pkgs-unstable.pkgsi686Linux.mesa;
    };

    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;

    services.blueman.enable = true;

    system.autoUpgrade = {
      enable = true;
      flake = inputs.self.outPath;
      flags = [ "--update-input" "nixpkgs" "-L" ];
      dates = "03:00";
      randomizedDelaySec = "45min";
    };

    nix.gc.automatic = true;
    nix.gc.dates = "daily";
    nix.gc.options = "--delete-older-than 3d";
    nix.settings.auto-optimise-store = true;
  };
}
