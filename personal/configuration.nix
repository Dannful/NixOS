{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ../modules/base-configuration.nix
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  base-config = {
    use-nvidia = true;
    use-steam = true;
    users = [
      {
        name = "dannly";
        password = "$6$uoaANV2.eLu/goEB$tjSshXgQLuZ533az.hiD7gsFgfrB2cxV/1LpdcEay7FfNIDJ14JXlw0fp8M33biz.VJNQZ5EC7Fs87fpQJMJq.";
        home-file-path = ./home.nix;
      }
    ];
    login = {
      display = {
        name = "DP-4";
        mode = "1920x1080@165";
      };
    };
  };

  hardware.xpadneo.enable = true;
  hardware.xone.enable = true;
  boot = {
    kernelModules = ["k10temp"];
    resumeDevice = "/dev/disk/by-uuid/5e66a786-5dc1-4827-a80c-359d9665f880";
    kernelParams = ["resume_offset=464121856"];
  };
  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;
    servers.ale = let
      geyser = pkgs.fetchurl {
        url = "https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/spigot";
        hash = "sha256-S4IpiQ4Aj29Ne4gsn/9SgNJfeLNjiY0q/lXbGftwcIs=";
      };
      floodgate = pkgs.fetchurl {
        url = "https://download.geysermc.org/v2/projects/floodgate/versions/latest/builds/latest/downloads/spigot";
        hash = "sha256-1kevbNh1zsZbJj/+TlEgTabptu24tIHTe6/czILxBdk=";
      };
    in {
      enable = true;
      autoStart = false;
      package = pkgs.paperServers.paper-1_21_11;

      symlinks = {
        "plugins/Geyser-Spigot.jar" = geyser;
        "plugins/Floodgate-Spigot.jar" = floodgate;
      };

      operators = {
        Dannly = "b6f190b5-c01b-3e9e-af5f-9a5f2d7cf733";
      };

      files = {
        "plugins/Geyser-Spigot/config.yml".value = {
          bedrock = {
            enabled = true;
            address = "0.0.0.0";
            port = 19132;
          };
          remote = {
            address = "127.0.0.1";
            port = 25565;
            auth-type = "floodgate";
          };
        };
      };

      serverProperties = {
        server-port = 25565;
        enforce-secure-profile = false;
        online-mode = false;
        difficulty = "hard";
        spawn-protection = 0;
        motd = "ooooooooi";
        max-players = 2;
        level-name = "ale";
      };

      jvmOpts = "-Xms4G -Xmx4G -XX:+UseG1GC";
    };
  };
  services.flatpak.enable = true;
  environment = {
    systemPackages = with pkgs; [
      btop
      lm_sensors
      javaPackages.compiler.temurin-bin.jdk-25
    ];
    sessionVariables = {
      WLR_NO_HARDWARE_CURSORS = "1";
      LIBVA_DRIVER_NAME = "nvidia";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    };
  };
  networking.firewall.allowedUDPPorts = [19132 5520];
}
