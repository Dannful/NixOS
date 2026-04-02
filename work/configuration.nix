{
  inputs,
  pkgs,
  config,
  ...
}: {
  imports = [
    ../modules/base-configuration.nix
    ./hardware-configuration.nix
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
  boot = {
    kernelModules = ["k10temp"];
    # resumeDevice = "/dev/disk/by-uuid/5e66a786-5dc1-4827-a80c-359d9665f880";
    # kernelParams = ["resume_offset=464121856"];
  };
  environment = {
    systemPackages = with pkgs; [
      btop
      lm_sensors
    ];
    sessionVariables = {
      WLR_NO_HARDWARE_CURSORS = "1";
      LIBVA_DRIVER_NAME = "nvidia";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    };
  };
  environment.etc."timezone".text = config.time.timeZone;
  networking = {
    firewall.allowedUDPPorts = [19132 5520];
    networkmanager.plugins = [
      pkgs.networkmanager-l2tp
    ];
    hosts = {
      "255.255.255.255" = ["broadcasthost"];
      "192.168.200.171" = ["dautoisp.int6tech.com.br"];
      "192.168.200.181" = ["poa181.int6tech.com.br"];
      "192.168.200.161" = ["autoisp.int6tech.com.br"];
      "192.168.203.67" = ["autoisp.brasiltecpar.com.br"];
      "192.168.200.141" = ["poa141.int6tech.com.br"];
      "192.168.200.175" = ["qa.int6tech.com.br"];
    };
  };
}
