{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixos.url = "github:nixos/nixpkgs/nixos-25.05";
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, nixos, home-manager, hyprland, quickshell, nvf, ... }@inputs:
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

          modules = [ ./work-laptop/configuration.nix ];
        };
      };
      templates = {
        csharp = {
          path = ./templates/csharp;
          description = "A C# development environment";
        };
      };
    };
}
