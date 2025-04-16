{ pkgs, lib }:

let
  latestRelease = pkgs.fetchurl {
    url =
      "https://api.github.com/repos/SylEleuth/gruvbox-plus-icon-pack/releases/latest";
    sha256 = "sha256-ABqU4Yakry5pCnFO/i552vG1lTxdMxUu/UDHGlR3Huk=";
  };
  versionTag = (lib.importJSON latestRelease).tag_name;
in pkgs.stdenv.mkDerivation {
  name = "gruvbox-plus";
  src = pkgs.fetchurl {
    url =
      "https://github.com/SylEleuth/gruvbox-plus-icon-pack/releases/download/${versionTag}/gruvbox-plus-icon-pack-${
        (lib.strings.substring 1 (lib.strings.stringLength versionTag))
        versionTag
      }.zip";
    sha256 = "sha256-D+SPhucHU4Riz0mzU1LnaEkkaQt+blJMAsA5r6fTAQ0=";
  };
  dontUnpack = true;
  installPhase = ''
    mkdir -p $out
    ${pkgs.unzip}/bin/unzip $src -d $out/
  '';

}
