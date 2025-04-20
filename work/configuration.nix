{ inputs, ... }:

{
  imports = [
    ../modules/base-configuration.nix
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  base-config = {
    use-nvidia = true;
    users = [{
      name = "work";
      password =
        "$6$8B3VVbnOEmwjl7eR$s3kosL.whd4c2pTLgmFPSw6vZHFLz8LRisQQTGYVaUtOkk0dq9O3GkCVUu/YltyhebxEKnovyH0yKbcQvwVdy/";
      home-file-path = ./home.nix;
    }];
    login = {
      display = {
        name = "DP-1";
        mode = "1920x1080@165";
      };
    };
  };
}
