{
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  pname = "scarlett2-firmware";
  version = "1.1";
  src = fetchFromGitHub {
    owner = "geoffreybennett";
    repo = "scarlett2-firmware";
    rev = "${version}";
    sha256 = "sha256-IrhLFBXymiVGYenYP+v/IRWJqMIakWWQNaorHzPv/LM=";
  };
  dontBuild = true;
  installPhase = ''
    mkdir -p $out/lib/firmware/scarlett2
    cp firmware/*.bin $out/lib/firmware/scarlett2/
  '';
}
