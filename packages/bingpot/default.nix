{
  lib,
  fetchCrate,
  rustPlatform,
  pkg-config,
  openssl,
}:
rustPlatform.buildRustPackage rec {
  pname = "bingpot";
  version = "0.1.0";

  src = fetchCrate {
    inherit pname version;
    hash = "sha256-oASla/sAe/XoMMLqhuEY5jOm2oGT5h+78gRIGhjeNoE=";
  };

  cargoHash = "sha256-SR1wa8E0bNBxIuDvvY2fmfOXzIUb3IL6DRqPSWL2t9E=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];

  meta = with lib; {
    description = "Simple command line utility and Rust library to download Bing images of the day programmatically.";
    homepage = "https://crates.io/crates/bingpot";
    license = licenses.mit;
    maintainers = [];
    mainProgram = "bingpot";
  };
}
