{
  alsa-scarlett-gui,
  fetchFromGitHub,
  latest-scarlett2-firmware,
}:
alsa-scarlett-gui.overrideAttrs (oldAttrs: rec {
  version = "1.0beta9";
  src = fetchFromGitHub {
    owner = "geoffreybennett";
    repo = "alsa-scarlett-gui";
    rev = "${version}";
    sha256 = "sha256-PAQj8Jamu2MY1wGLnaWnvm9OfsXE0YTSDhfiaQLajB8=";
  };
  postPatch = ''
    substituteInPlace scarlett2-firmware.h \
      --replace-fail '"/usr/lib/firmware/scarlett2"' '"${latest-scarlett2-firmware}/lib/firmware/scarlett2"'
  '';
})
