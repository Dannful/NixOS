{
  inputs,
  pkgs,
  config,
  ...
}: let
  int6-vpn-name = "int6-vpn";
in {
  imports = [
    ../modules/base-configuration.nix
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  base-config = {
    use-nvidia = true;
    users = [
      {
        name = "work";
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

  boot.kernelModules = ["k10temp"];

  environment = {
    systemPackages = with pkgs; [
      btop
      lm_sensors
    ];
  };
  environment.etc."timezone".text = config.time.timeZone;
  networking.networkmanager.plugins = [
    pkgs.networkmanager-l2tp
  ];
}
