{nixpkgs, ...}: {
  x86_64-linux = nixpkgs.legacyPackages."x86_64-linux".alejandra;
}
