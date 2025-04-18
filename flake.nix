{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos.url = "github:nixos/nixpkgs/nixos-unstable";
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nixos, home-manager, hyprland, ... }@inputs:
    let system = "x86_64-linux";
    in {
      nixosConfigurations = {
        personal = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs system; };

          modules = [ ./personal/configuration.nix ];

        };
        work = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs system; };

          modules = [ ./work/configuration.nix ];
        };
        work-laptop = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs system; };

          modules = [
            ./work-laptop/configuration.nix
            ({ ... }: { programs.command-not-found.enable = false; })
          ];
        };
      };
    };
}
