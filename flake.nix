{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    prismlauncher.url = "github:PrismLauncher/PrismLauncher/develop";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.poseidon = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
      ];
    };
  };
}
