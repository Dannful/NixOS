{
  inputs,
  pkgs,
  ...
}: let
  int6-vpn-name = "int6-vpn";
in {
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

  boot.kernelModules = ["k10temp" "nf_conntrack_pptp"];
  environment = {
    systemPackages = with pkgs; [
      btop
      lm_sensors
      ppp
      pptp
    ];
    etc."ppp/options".text = "";
    etc."ppp/peers/${int6-vpn-name}".text = ''
      pty "${pkgs.pptp}/bin/pptp SERVER_ADDRESS --nolaunchpppd"
      name "YOUR_USERNAME"
      remotename PPTP

      lock
      noauth
      nobsdcomp
      nodeflate

      require-mppe-128
      defaultroute
      replacedefaultroute

      persist
      maxfail 0
      holdoff 10
      ipparam ${int6-vpn-name}
    '';
  };
  systemd.services.pptp-vpn = {
    description = "PPTP VPN Client";
    after = ["network-online.target"];
    wants = ["network-online.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "forking";
      ExecStart = "${pkgs.ppp}/bin/pon ${int6-vpn-name}";
      ExecStop = "${pkgs.ppp}/bin/poff ${int6-vpn-name}";
      Restart = "always";
      RestartSec = "5";
    };
  };
}
