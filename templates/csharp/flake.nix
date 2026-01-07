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
        config = {
          permittedInsecurePackages = ["dotnet-sdk-6.0.428" "aspnetcore-runtime-6.0.36"];
        };
      };
      dotnetPackages = pkgs.dotnetCorePackages.combinePackages [
        pkgs.dotnetCorePackages.sdk_6_0
        pkgs.dotnetCorePackages.sdk_9_0
        pkgs.dotnetCorePackages.aspnetcore_6_0
      ];
    in {
      devShell = pkgs.mkShell {
        buildInputs = [dotnetPackages];
        shellHook = ''
          export DOTNET_ROOT="${dotnetPackages}";
        '';
      };
    });
}
