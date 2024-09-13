{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ nixpkgs, ... }:
  let
    hosts = [
      { name = "epsilon"; hardware = "laptop"; system = "x86_64-linux"; }
    ];
    # systems = nixpkgs.lib.unique (map (h: h.system) hosts);
    # forAllSystems = nixpkgs.lib.genAttrs systems;
    common = {
      inherit hosts nixpkgs inputs;
    };
  in {
    nixosConfigurations = import ./hosts ( common // {
      isNixOs = true;
    });
    # packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
  };
}
