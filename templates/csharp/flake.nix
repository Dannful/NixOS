{
  inputs = {utils.url = "github:numtide/flake-utils";};
  outputs = {
    self,
    nixpkgs,
    utils,
  }:
    utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
      };
      dotnetPackages = pkgs.dotnetCorePackages.combinePackages [
        pkgs.dotnetCorePackages.sdk_8_0
        pkgs.dotnetCorePackages.sdk_9_0
        pkgs.dotnetCorePackages.aspnetcore_8_0
      ];
      dotnetShell = pkgs.mkShell {
        packages = [
          (pkgs.dotnetCorePackages.combinePackages [
            pkgs.dotnetCorePackages.sdk_8_0
            pkgs.dotnetCorePackages.sdk_9_0
            pkgs.dotnetCorePackages.aspnetcore_8_0
          ])
        ];
        env = {
          DOTNET_ROOT = "${dotnetPackages}";
        };
      };
    in {
      devShells.default = dotnetShell;
    });
}
