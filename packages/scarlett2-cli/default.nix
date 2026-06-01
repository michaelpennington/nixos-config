{
  stdenv,
  fetchFromGitHub,
  pkg-config,
  alsa-lib,
  openssl,
  latest-scarlett2-firmware,
}:
stdenv.mkDerivation rec {
  pname = "scarlett2-cli";
  version = "1.0";
  src = fetchFromGitHub {
    owner = "geoffreybennett";
    repo = "scarlett2";
    rev = "${version}";
    sha256 = "sha256-GfWfIOQfH5SoBdExIT1p/OHXJG2pwzTW/RS8Rs4QSGQ=";
  };
  nativeBuildInputs = [pkg-config];
  buildInputs = [alsa-lib openssl];
  postPatch = ''
    substituteInPlace main.c \
      --replace-fail '"/usr/lib/firmware/scarlett2"' '"${latest-scarlett2-firmware}/lib/firmware/scarlett2"'
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp scarlett2 $out/bin
  '';
}
