{ stdenv, fetchFromGitHub, system }:
stdenv.mkDerivation {
  name = "fzf-tab-completion";
  version = "1112259";
  system = system;

  src = fetchFromGitHub {
    owner = "lincheney";
    repo = "fzf-tab-completion";
    rev = "11122590127ab62c51dd4bbfd0d432cee30f9984";
    sha256 = "sha256-ds+GgCTXXavaELCy0MxAGHTPp2MFoFohm/gPkQCRuXU=";
  };

  # buildPhase = ''
  #   mkdir -p bin
  #   echo 'dirname $0' > bin/get-fzf-tab-completion-dir.sh
  #   chmod +x bin/get-fzf-tab-completion-dir.sh
  # '';

  installPhase = "cp -r . $out/";
}
