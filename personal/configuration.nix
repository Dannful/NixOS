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

  boot.kernelModules = ["v4l2loopback" "k10temp"];
  boot.extraModulePackages = [pkgs.linuxPackages.v4l2loopback];
  environment.systemPackages = with pkgs; [
    btop
    lm_sensors
  ];
}
