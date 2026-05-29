{ inputs, ... }: {
  default = final: prev: {
    latest-scarlett2-firmware = final.callPackage ../packages/scarlett2-firmware {};
    latest-alsa-scarlett-gui = final.callPackage ../packages/alsa-scarlett-gui {};
    latest-scarlett2-cli = final.callPackage ../packages/scarlett2-cli {};
    pianoteq-routed = final.callPackage ../packages/pianoteq-routed {
      pianoteq = inputs.pianoteq.packages.${final.stdenv.hostPlatform.system}.default;
    };
  };
}
