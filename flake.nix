{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    prismlauncher.url = "github:PrismLauncher/PrismLauncher/develop";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations.poseidon = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
	home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
	  home-manager.useUserPackages = true;

	  home-manager.users.mpennington = import ./home.nix;
	}
      ];
    };
  };
}
