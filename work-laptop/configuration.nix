{inputs, ...}: {
  imports = [
    ../modules/base-configuration.nix
    ./hardware-configuration.nix
    ../modules/nginx/work.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  base-config = {
    users = [
      {
        name = "vinidan";
        password = "$6$uoaANV2.eLu/goEB$tjSshXgQLuZ533az.hiD7gsFgfrB2cxV/1LpdcEay7FfNIDJ14JXlw0fp8M33biz.VJNQZ5EC7Fs87fpQJMJq.";
        home-file-path = ./home.nix;
      }
    ];
  };
}
