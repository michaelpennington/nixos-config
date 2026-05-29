{inputs, ...}:
# Entry point for the 'poseidon' NixOS configuration
inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = {inherit inputs;};

  modules = [
    # Main host configuration
    ../../hosts/poseidon

    # Home Manager integration
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = {inherit inputs;};

      # Per-user Home Manager configuration
      home-manager.users.mpennington = import ../../hosts/poseidon/home.nix;
    }
  ];
}
