{...}: {
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts = {
      "keycloak" = {
        locations = {
          "/" = {
            proxyPass = "http://localhost:8080";
          };
        };
      };

      "application" = {
        locations."/" = {
          proxyPass = "http://localhost:3000";
        };
      };
    };
  };
  networking.hosts = {
    "127.0.0.1" = ["keycloak" "application"];
  };
}
