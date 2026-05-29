{inputs, ...}: {
  # Define the formatter used for `nix fmt`
  x86_64-linux = inputs.nixpkgs.legacyPackages."x86_64-linux".alejandra;
}
