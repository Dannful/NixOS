{ inputs, ... }:

{
  imports = [
    ../modules/base-configuration.nix
    ../modules/base-hardware-configuration.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  base-hardware-config = { };
  base-config = {
    users = [{
      name = "Vinícius Daniel";
      password =
        "$6$8B3VVbnOEmwjl7eR$s3kosL.whd4c2pTLgmFPSw6vZHFLz8LRisQQTGYVaUtOkk0dq9O3GkCVUu/YltyhebxEKnovyH0yKbcQvwVdy/";
      home-file-path = ./home.nix;
    }];
  };
}
