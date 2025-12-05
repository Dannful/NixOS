{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ../modules/base-configuration.nix
    ./hardware-configuration.nix
    ../modules/nginx/work.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  base-config = {
    use-nvidia = true;
    users = [
      {
        name = "work";
        password = "$6$8B3VVbnOEmwjl7eR$s3kosL.whd4c2pTLgmFPSw6vZHFLz8LRisQQTGYVaUtOkk0dq9O3GkCVUu/YltyhebxEKnovyH0yKbcQvwVdy/";
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

  boot.kernelModules = ["v4l2loopback"];
  boot.extraModulePackages = [pkgs.linuxPackages.v4l2loopback];
}
