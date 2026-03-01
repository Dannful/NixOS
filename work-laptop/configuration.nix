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
        password = "$6$8B3VVbnOEmwjl7eR$s3kosL.whd4c2pTLgmFPSw6vZHFLz8LRisQQTGYVaUtOkk0dq9O3GkCVUu/YltyhebxEKnovyH0yKbcQvwVdy/";
        home-file-path = ./home.nix;
      }
    ];
  };
  services.openvpn.servers = {
    workVPN = {
      config = ''
        client
        dev tun
        proto udp
        remote int6.vpn.com.br 1194

        ca   /etc/nixos/vpn/int6/ca.crt
        cert /etc/nixos/vpn/int6/spadotto-nixos.crt
        key  /etc/nixos/vpn/int6/spadotto-nixos.key

        # Standard Security Settings
        cipher AES-256-GCM
        auth SHA256
        resolv-retry infinite
        nobind
      '';
      autoStart = true;
      updateResolvConf = true;
    };
  };
}
