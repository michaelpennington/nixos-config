{inputs, ...}: let
  # Read the hosts directory to find all available hosts dynamically
  hosts = builtins.attrNames (inputs.nixpkgs.lib.attrsets.filterAttrs (n: v: v == "directory") (builtins.readDir ../hosts));

  # Function to create a Colmena node configuration for a given host
  mkNode = name: {
    imports = [
      ../hosts/${name}
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = {inherit inputs;};
        home-manager.users.mpennington = import ../hosts/${name}/home.nix;
      }
    ];

    # Colmena specific node deployment settings (can be overridden in the host's default.nix)
    deployment = {
      targetHost = name; # Default target host to the node name
      targetUser = "root";
    };
  };
in
  {
    meta = {
      nixpkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";
      specialArgs = {inherit inputs;};
    };
  }
  // (builtins.listToAttrs (map (name: {
      inherit name;
      value = mkNode name;
    })
    hosts))
