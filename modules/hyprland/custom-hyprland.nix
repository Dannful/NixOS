{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) mkOption types;
  cfg = config.custom-hyprland;

  lua = lib.generators.mkLuaInline;
  mod = "SUPER";
  alt = "ALT";

  accentGradient = {
    colors = ["rgba(cba6f7ff)" "rgba(89b4faff)"];
    angle = 45;
  };

  dsp = {
    exec = cmd: lua ''hl.dsp.exec_cmd("${cmd}")'';
    close = lua "hl.dsp.window.close()";
    fullscreen = lua "hl.dsp.window.fullscreen()";
    pseudo = lua "hl.dsp.window.pseudo()";
    float = lua ''hl.dsp.window.float({ action = "toggle" })'';
    focus = dir: lua ''hl.dsp.focus({ direction = "${dir}" })'';
    move = dir: lua ''hl.dsp.window.move({ direction = "${dir}" })'';
    resize = x: y: lua ''hl.dsp.window.resize({ x = ${toString x}, y = ${toString y} })'';
    mouseResize = lua "hl.dsp.window.resize()";
    drag = lua "hl.dsp.window.drag()";
    toggleGroup = lua "hl.dsp.group.toggle()";
    groupNext = lua "hl.dsp.group.next()";
    groupPrev = lua "hl.dsp.group.prev()";
    toggleSpecial = name: lua ''hl.dsp.workspace.toggle_special("${name}")'';
    moveToSpecial = name: lua ''hl.dsp.window.move({ workspace = "special:${name}" })'';
    focusWorkspace = ws: lua ''hl.dsp.focus({ workspace = "${toString ws}" })'';
    moveToWorkspace = ws: lua ''hl.dsp.window.move({ workspace = "${toString ws}" })'';
  };

  bind = keys: dispatcher: {_args = [keys dispatcher];};
  bindOpts = keys: dispatcher: opts: {_args = [keys dispatcher opts];};

  workspaceBinds = builtins.concatLists (builtins.genList (i: let
      ws = i + 1;
    in [
      (bind "${mod} + code:1${toString i}" (dsp.focusWorkspace ws))
      (bind "${mod} + SHIFT + code:1${toString i}" (dsp.moveToWorkspace ws))
    ])
    9);
in {
  options.custom-hyprland = {
    enable = lib.mkEnableOption "custom Hyprland";
    nvidia = mkOption {
      description = "Whether to use NVIDIA";
      type = types.bool;
      default = false;
    };
    monitors = mkOption {
      description = "A list containing all monitor configurations";
      type = types.listOf (types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            description = "Name of the monitor.";
            example = "DP-1";
          };
          resolution = mkOption {
            type = types.str;
            description = "Resolution for the monitor.";
            example = "1920x1080";
          };
          refresh-rate = mkOption {
            type = types.str;
            description = "Refresh rate for the monitor.";
            example = "60.00";
          };
          position = mkOption {
            type = types.str;
            description = "The monitor's position.";
            example = "1920x0";
          };
        };
      });
    };
  };

  config = lib.mkIf cfg.enable (let
    gstPlugins = with pkgs.gst_all_1; [
      gstreamer
      gst-plugins-base
      gst-plugins-good
      gst-plugins-bad
      gst-plugins-ugly
      gst-libav
    ];

    screenshot = pkgs.writeShellScriptBin "screenshot" ''
      mode="''${1:-region}"
      dir="$HOME/Pictures/Screenshots"
      mkdir -p "$dir"
      ${pkgs.hyprshot}/bin/hyprshot -z -m "$mode" --raw | ${pkgs.satty}/bin/satty \
        --filename - \
        --resize smart \
        --early-exit \
        --copy-command ${pkgs.wl-clipboard}/bin/wl-copy \
        --output-filename "$dir/satty-$(date +%Y%m%d-%H%M%S).png"
    '';

    quickshell-wrapped = pkgs.symlinkJoin {
      name = "quickshell-with-multimedia";
      paths = [inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default];
      buildInputs = [pkgs.makeWrapper];
      postBuild = ''
        wrapProgram $out/bin/quickshell \
          --prefix QML2_IMPORT_PATH : ${pkgs.qt6.qtmultimedia}/${pkgs.qt6.qtbase.qtQmlPrefix} \
          --prefix QT_PLUGIN_PATH : ${pkgs.qt6.qtmultimedia}/${pkgs.qt6.qtbase.qtPluginPrefix} \
          --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : ${pkgs.lib.makeSearchPath "lib/gstreamer-1.0" gstPlugins} \
          --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath (gstPlugins ++ [pkgs.qt6.qtmultimedia])}
      '';
    };
  in {
    home.packages =
      [quickshell-wrapped]
      ++ (with pkgs; [
        alsa-utils
        wl-clipboard
        cliphist
        rofi
        playerctl
        brightnessctl
        hyprshot
        grim
        slurp
        satty
      ]);
    home.file = {
      ".config/rofi/config.rasi" = {text = ''@theme "arthur"'';};
      ".config/quickshell" = {
        source = ../quickshell;
        recursive = true;
      };
    };
    programs.hyprlock.enable = true;
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
        };
        listener = [
          {
            timeout = 150;
            on-timeout = "brightnessctl -s set 10";
            on-resume = "brightnessctl -r";
          }
          {
            timeout = 300;
            on-timeout = "loginctl lock-session";
          }
          {
            timeout = 330;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on && brightnessctl -r";
          }
          {
            timeout = 1800;
            on-timeout = "systemctl suspend";
          }
        ];
      };
    };

    systemd.user.services.quickshell = {
      Unit = {
        Description = "Quickshell Panel";
        After = ["graphical-session-pre.target"];
        PartOf = ["graphical-session.target"];
      };
      Service = {
        ExecStart = "${quickshell-wrapped}/bin/quickshell";
        Restart = "on-failure";
      };
      Install = {WantedBy = ["graphical-session.target"];};
    };

    wayland.windowManager.hyprland = {
      enable = true;
      configType = "lua";
      xwayland.enable = true;
      systemd.enable = false;
      package =
        inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;

      extraConfig = lib.optionalString cfg.nvidia ''
        hl.env("LIBVA_DRIVER_NAME", "nvidia")
        hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
      '';

      settings = {
        config = {
          general = {
            gaps_in = 5;
            gaps_out = {
              top = 58;
              right = 18;
              bottom = 18;
              left = 63;
            };
            border_size = 2;
            col = {
              active_border = accentGradient;
              inactive_border = "rgba(313244cc)";
            };
            layout = "dwindle";
          };
          cursor = {no_hardware_cursors = true;};
          input = {
            kb_layout = "us";
            kb_variant = "alt-intl";
          };
          decoration = {
            rounding = 10;
            blur = {
              enabled = true;
              size = 4;
              passes = 3;
              new_optimizations = true;
              ignore_opacity = true;
            };
            shadow = {
              enabled = true;
              range = 10;
              render_power = 3;
              color = "rgba(1a1a1aee)";
            };
          };
          animations = {
            enabled = true;
          };
          dwindle = {
            preserve_split = true;
          };
          misc = {
            animate_manual_resizes = true;
            animate_mouse_windowdragging = true;
          };
          group = {
            col = {
              border_active = accentGradient;
              border_inactive = "rgba(313244cc)";
            };
            groupbar = {
              font_size = 12;
              gradients = true;
              col = {
                active = "rgba(cba6f7ff)";
                inactive = "rgba(313244cc)";
              };
            };
          };
          binds = {drag_threshold = 10;};
        };

        monitor =
          map (monitor: {
            inherit (monitor) position;

            output = monitor.name;
            mode = "${monitor.resolution}@${monitor.refresh-rate}";
            scale = "1.0";
          })
          cfg.monitors;

        curve = [
          {
            _args = [
              "overshot"
              {
                type = "bezier";
                points = lua "{ {0.05, 0.9}, {0.1, 1.05} }";
              }
            ];
          }
          {
            _args = [
              "smoothOut"
              {
                type = "bezier";
                points = lua "{ {0.36, 0}, {0.66, -0.56} }";
              }
            ];
          }
          {
            _args = [
              "smoothIn"
              {
                type = "bezier";
                points = lua "{ {0.25, 1}, {0.5, 1} }";
              }
            ];
          }
          {
            _args = [
              "snappy"
              {
                type = "bezier";
                points = lua "{ {0.2, 1}, {0.2, 1} }";
              }
            ];
          }
          {
            _args = [
              "linear"
              {
                type = "bezier";
                points = lua "{ {0, 0}, {1, 1} }";
              }
            ];
          }
        ];

        animation = [
          {
            leaf = "windows";
            enabled = true;
            speed = 5;
            bezier = "overshot";
            style = "slide";
          }
          {
            leaf = "windowsOut";
            enabled = true;
            speed = 4;
            bezier = "smoothOut";
            style = "slide";
          }
          {
            leaf = "windowsMove";
            enabled = true;
            speed = 4;
            bezier = "snappy";
          }
          {
            leaf = "border";
            enabled = true;
            speed = 10;
            bezier = "default";
          }
          {
            leaf = "borderangle";
            enabled = true;
            speed = 100;
            bezier = "linear";
            style = "loop";
          }
          {
            leaf = "fade";
            enabled = true;
            speed = 10;
            bezier = "smoothIn";
          }
          {
            leaf = "fadeDim";
            enabled = true;
            speed = 10;
            bezier = "smoothIn";
          }
          {
            leaf = "layers";
            enabled = true;
            speed = 4;
            bezier = "snappy";
            style = "slide";
          }
          {
            leaf = "workspaces";
            enabled = true;
            speed = 6;
            bezier = "snappy";
            style = "slide";
          }
          {
            leaf = "specialWorkspace";
            enabled = true;
            speed = 6;
            bezier = "overshot";
            style = "slidevert";
          }
        ];

        on = {
          _args = [
            "hyprland.start"
            (lua ''
              function()
                hl.exec_cmd("${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store")
              end'')
          ];
        };

        bind =
          [
            # App launchers
            (bind "${alt} + B" (dsp.exec "${pkgs.firefox}/bin/firefox"))
            (bind "${alt} + F" (dsp.exec "${pkgs.nautilus}/bin/nautilus"))
            (bind "${alt} + D" (dsp.exec "${pkgs.discord}/bin/discord"))
            (bind "${mod} + Return" (dsp.exec "${pkgs.kitty}/bin/kitty"))
            (bind "${mod} + D" (dsp.exec "${pkgs.rofi}/bin/rofi -show drun"))

            # Window management
            (bind "${mod} + Q" (dsp.exec "hyprctl kill"))
            (bind "${mod} + C" dsp.close)
            (bind "${mod} + F" dsp.fullscreen)
            (bind "${mod} + P" dsp.pseudo)

            # Screenshots
            (bind "Print" (dsp.exec "${screenshot}/bin/screenshot region"))
            (bind "SHIFT + Print" (dsp.exec "${screenshot}/bin/screenshot output"))
            (bind "${mod} + Print" (dsp.exec "${screenshot}/bin/screenshot window"))

            # Clipboard history
            (bind "${mod} + V" (dsp.exec "${pkgs.cliphist}/bin/cliphist list | ${pkgs.rofi}/bin/rofi -dmenu -display-columns 2 | ${pkgs.cliphist}/bin/cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy"))

            # Quick lock screen
            (bind "${mod} + L" (dsp.exec "loginctl lock-session"))

            # Window focus movement
            (bind "${mod} + left" (dsp.focus "left"))
            (bind "${mod} + right" (dsp.focus "right"))
            (bind "${mod} + up" (dsp.focus "up"))
            (bind "${mod} + down" (dsp.focus "down"))

            # Move windows
            (bind "${mod} + SHIFT + left" (dsp.move "left"))
            (bind "${mod} + SHIFT + right" (dsp.move "right"))
            (bind "${mod} + SHIFT + up" (dsp.move "up"))
            (bind "${mod} + SHIFT + down" (dsp.move "down"))

            # Window groups (tabbed)
            (bind "${mod} + G" dsp.toggleGroup)
            (bind "${mod} + tab" dsp.groupNext)
            (bind "${mod} + SHIFT + tab" dsp.groupPrev)

            # Scratchpad (special workspace)
            (bind "${mod} + S" (dsp.toggleSpecial "magic"))
            (bind "${mod} + SHIFT + S" (dsp.moveToSpecial "magic"))

            # Scroll through existing workspaces with mouse
            (bind "${mod} + mouse_down" (dsp.focusWorkspace "e+1"))
            (bind "${mod} + mouse_up" (dsp.focusWorkspace "e-1"))

            # Resize active window with keyboard (repeating)
            (bindOpts "${mod} + ${alt} + left" (dsp.resize (-50) 0) {repeating = true;})
            (bindOpts "${mod} + ${alt} + right" (dsp.resize 50 0) {repeating = true;})
            (bindOpts "${mod} + ${alt} + up" (dsp.resize 0 (-50)) {repeating = true;})
            (bindOpts "${mod} + ${alt} + down" (dsp.resize 0 50) {repeating = true;})

            # Mouse move/resize/float
            (bindOpts "${mod} + mouse:272" dsp.drag {mouse = true;})
            (bindOpts "${mod} + mouse:273" dsp.mouseResize {mouse = true;})
            (bindOpts "${mod} + mouse:272" dsp.float {mouse = true;})

            # Volume/brightness (repeating, locked)
            (bindOpts "XF86AudioRaiseVolume" (dsp.exec "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+") {
              repeating = true;
              locked = true;
            })
            (bindOpts "XF86AudioLowerVolume" (dsp.exec "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-") {
              repeating = true;
              locked = true;
            })
            (bindOpts "XF86MonBrightnessUp" (dsp.exec "${pkgs.brightnessctl}/bin/brightnessctl s 10%+") {
              repeating = true;
              locked = true;
            })
            (bindOpts "XF86MonBrightnessDown" (dsp.exec "${pkgs.brightnessctl}/bin/brightnessctl s 10%-") {
              repeating = true;
              locked = true;
            })

            # Media keys (locked)
            (bindOpts "XF86AudioMute" (dsp.exec "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle") {locked = true;})
            (bindOpts "XF86AudioPlay" (dsp.exec "playerctl play-pause") {locked = true;})
            (bindOpts "XF86AudioPrev" (dsp.exec "playerctl previous") {locked = true;})
            (bindOpts "XF86AudioNext" (dsp.exec "playerctl next") {locked = true;})
          ]
          ++ workspaceBinds;
      };
    };
  });
}
