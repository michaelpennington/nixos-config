{inputs, ...}: {
  # Custom overlays for the flake
  default = final: prev: {
    # Custom packages defined in the ./packages directory
    bingpot = final.callPackage ../packages/bingpot {};
    latest-scarlett2-firmware = final.callPackage ../packages/scarlett2-firmware {};
    latest-alsa-scarlett-gui = final.callPackage ../packages/alsa-scarlett-gui {};
    latest-scarlett2-cli = final.callPackage ../packages/scarlett2-cli {};

    # Pianoteq routing with dependency injection from the pianoteq flake input
    pianoteq-routed = final.callPackage ../packages/pianoteq-routed {
      pianoteq = inputs.pianoteq.packages.${final.stdenv.hostPlatform.system}.default;
    };
  };
}
