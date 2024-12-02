{ inputs, ... }:

{
  imports = [
    ../modules/base-configuration.nix
    ../modules/base-hardware-configuration.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  base-hardware-config = {
    use-nvidia = true;
  };

  base-config = {
    use-nvidia = true;
    use-steam = true;
    users = [{
      name = "dannly";
      password =
        "$6$uoaANV2.eLu/goEB$tjSshXgQLuZ533az.hiD7gsFgfrB2cxV/1LpdcEay7FfNIDJ14JXlw0fp8M33biz.VJNQZ5EC7Fs87fpQJMJq.";
      home-file-path = ./home.nix;
    }];
  };
}
