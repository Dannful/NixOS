{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) mkOption types;
  cfg = config.base-config;

  custom-sddm-astronaut = pkgs.sddm-astronaut.override {
    themeConfig = {
      Background =
        if (cfg.login != null && cfg.login.wallpaper != null)
        then (toString cfg.login.wallpaper)
        else "${pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/Keyitdev/sddm-astronaut-theme/refs/heads/master/Backgrounds/pixel_sakura.gif";
          hash = "sha256-wqfnUspZY9UlCuCKSum49/HHz3A9vndNc7caspvL+7M=";
        }}";
    };
    embeddedTheme = "astronaut";
  };
in {
  options.base-config = {
    users = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            name = mkOption {
              type = types.str;
              description = "User name";
              example = "default";
            };
            password = mkOption {
              type = types.str;
              description = "User password in SHA512 hash";
              example = "$6$l8tWRCtkcDiV17p4$zsEIc9/vY62pR2kFhUnO9R/hWdGDTQyMIKREVpNUSZl6cFeUDNz3/9dK.CeQ2vwBk45pEeNKT7T9rb4d1pLLn/";
            };
            groups = mkOption {
              type = types.listOf types.str;
              description = "Extra groups for the user";
              example = "[]";
              default = [];
            };
            home-file-path = mkOption {
              type = types.path;
              description = "Home nix file path";
              example = "./home.nix";
            };
          };
        }
      );
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
    login = mkOption {
      type = types.nullOr (
        types.submodule {
          options = {
            wallpaper = mkOption {
              type = types.nullOr types.path;
              description = "Path to the image";
              default = null;
            };
            display = mkOption {
              type = types.nullOr (
                types.submodule {
                  options = {
                    name = mkOption {
                      type = types.str;
                      description = "Name of the output";
                      example = "DP-1";
                    };
                    mode = mkOption {
                      type = types.str;
                      description = "Mode of the output";
                      example = "1920x1080@60";
                    };
                  };
                }
              );
              description = "Display settings";
              default = null;
            };
          };
        }
      );
      description = "Settings for the login screen";
      default = null;
    };
  };

  config = {
    # --- Localization & Time ---
    time.timeZone = "America/Sao_Paulo";
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
    console.useXkbConfig = true;

    # --- Boot & Hardware ---
    boot = {
      loader = {
        systemd-boot.enable = true;
        systemd-boot.configurationLimit = 10;
        efi.canTouchEfiVariables = true;
      };
      kernelModules = ["v4l2loopback"];
      extraModulePackages = [config.boot.kernelPackages.v4l2loopback];
    };

    hardware = {
      nvidia = lib.mkIf cfg.use-nvidia {
        modesetting.enable = true;
        powerManagement.enable = false;
        powerManagement.finegrained = false;
        open = false;
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.stable;
      };
      graphics = {
        enable = true;
        enable32Bit = true;
      };
      enableAllFirmware = true;
      bluetooth.enable = true;
      bluetooth.powerOnBoot = true;
    };

    # --- Networking ---
    networking = {
      hostName = "nixos";
      networkmanager.enable = true;
      hosts = {
        "127.0.0.1" = [
          "keycloak"
          "s3"
          "vanescola-router"
          "vanescola-portal"
        ];
      };
    };

    # --- Nix Configuration ---
    nix = {
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        auto-optimise-store = true;
      };
      gc = {
        automatic = true;
        dates = "daily";
        options = "--delete-older-than 3d";
      };
    };

    # --- Nixpkgs Configuration ---
    nixpkgs = {
      config.allowUnfree = true;
      overlays = [
        (_self: super: {
          gnome = super.gnome.overrideScope (
            _gself: gsuper: {
              nautilus = gsuper.nautilus.overrideAttrs (nsuper: {
                buildInputs =
                  nsuper.buildInputs
                  ++ (with pkgs.gst_all_1; [
                    gst-plugins-good
                    gst-plugins-bad
                  ]);
              });
            }
          );
        })
      ];
    };

    # --- Services ---
    services = {
      # X11 & Display Manager
      xserver = {
        enable = true;
        xkb = {
          layout = "us";
          variant = "alt-intl";
        };
        videoDrivers = lib.mkIf cfg.use-nvidia ["nvidia"];
      };

      displayManager.sddm = {
        enable = true;
        wayland.enable = true;
        package = pkgs.kdePackages.sddm;
        theme = "sddm-astronaut-theme";
        extraPackages = [custom-sddm-astronaut];
        settings = let
          westonConfigFile = pkgs.writeText "weston.ini" (
            ''
              [keyboard]
              keymap_layout=us
              keymap_model=pc104
              keymap_options=terminate:ctrl_alt_bksp
              keymap_variant=alt-intl

              [libinput]
              enable-tap=true
              left-handed=false

            ''
            + lib.optionalString (cfg.login != null && cfg.login.display != null) ''
              [output]
              name=${cfg.login.display.name}
              mode=${cfg.login.display.mode}
            ''
          );
        in {
          Wayland = {
            CompositorCommand = "${pkgs.weston}/bin/weston --shell=kiosk -c ${westonConfigFile}";
          };
        };
      };

      # Audio
      pulseaudio.enable = false;
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        wireplumber.enable = true;
      };

      # Utilities
      gvfs.enable = true;
      printing.enable = true;
      blueman.enable = true;
      hypridle.enable = true;
      dbus.enable = true;
      dbus.packages = [pkgs.swaynotificationcenter];
    };

    # Enable systemd user service for swaync
    systemd.packages = [pkgs.swaynotificationcenter];

    # --- Virtualisation ---
    virtualisation.docker.enable = true;

    # --- Programs ---
    programs = {
      dconf.enable = true;
      zsh.enable = true;
      firefox.enable = true;

      hyprland = {
        enable = true;
        package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
        portalPackage =
          inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      };

      steam = lib.mkIf cfg.use-steam {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
        gamescopeSession.enable = true;
      };
      gamemode.enable = cfg.use-steam;
    };

    # --- Portals & MIME ---
    xdg.portal = {
      enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-gtk];
      config = {
        common = {
          default = ["gtk"];
        };
        hyprland = {
          default = ["gtk"];
          "org.freedesktop.impl.portal.Screencast" = ["hyprland"];
          "org.freedesktop.impl.portal.Screenshot" = ["hyprland"];
        };
      };
    };

    xdg.mime.defaultApplications = {
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
      "x-scheme-handler/unknown" = "firefox.desktop";
      "application/pdf" = "org.pwmt.zathura.desktop";
      "image/jpeg" = "feh.desktop";
      "image/png" = "feh.desktop";
      "image/gif" = "feh.desktop";
      "image/bmp" = "feh.desktop";
      "image/svg+xml" = "feh.desktop";
      "image/webp" = "feh.desktop";
    };

    # --- Users & Home Manager ---
    users.users = builtins.listToAttrs (
      builtins.map (user: {
        inherit (user) name;
        value = {
          hashedPassword = user.password;
          isNormalUser = true;
          description = user.name;
          extraGroups =
            [
              "networkmanager"
              "wheel"
              "docker"
            ]
            ++ user.groups;
          packages = [];
          shell = pkgs.zsh;
        };
      })
      cfg.users
    );

    home-manager = {
      extraSpecialArgs = {inherit inputs;};
      users = builtins.listToAttrs (
        builtins.map (user: {
          inherit (user) name;
          value = import user.home-file-path;
        })
        cfg.users
      );
      backupFileExtension = "backup";
    };

    # --- Environment ---
    environment.systemPackages = with pkgs;
      [
        # Home manager
        home-manager

        # Core / Terminals / Editors
        kitty
        vim
        nixd
        nil
        nixfmt-classic

        # Utilities
        ffmpeg
        jq
        zip
        unzip
        libnotify
        gnome-system-monitor
        kdePackages.qtdeclarative

        # File Management
        nautilus

        # UI / Theming
        feh
        swaynotificationcenter
        custom-sddm-astronaut

        # Media / Social
        discord
        youtube-music
        zathura
        pavucontrol
      ]
      ++ lib.optionals cfg.use-steam [
        pkgs.protonup-ng
        pkgs.mangohud
        pkgs.wineWow64Packages.waylandFull
        pkgs.winetricks
      ]
      ++ lib.optionals cfg.use-nvidia [pkgs.egl-wayland];

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };

    # --- Fonts ---
    fonts.packages = with pkgs; [
      nerd-fonts.fira-code
      iosevka
      hack-font
      material-symbols
    ];
    fonts.fontconfig.defaultFonts = {
      serif = ["FiraCode Nerd Font"];
      sansSerif = ["FiraCode Nerd Font"];
      monospace = ["FiraCode Nerd Font Mono"];
    };

    system.stateVersion = "24.05";
  };
}
