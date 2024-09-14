{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ nixpkgs, ... }:
  let
    # List of hosts to generate
    # `name` specifies which configuration to lookup
    # `hostname` defaults to name if not specified. lookup from env if we don't care
    # `hardware` specifies which hardware_configuration to lookup. ignored for home-manager
    hosts = [
      { name = "epsilon"; hardware = "laptop"; system = "x86_64-linux"; }
    ];
    nixOsFilter = nixpkgs.lib.filter (h: builtins.hasAttr "hardware" h);
    mkHosts = import ./hosts { inherit nixpkgs inputs; };
  in {
    # Make nixos configs for only hosts that have hardware associated
    nixosConfigurations = mkHosts.mkNixOsHosts (nixOsFilter hosts);
    # Make home-manager configs for all hosts
    homeConfigurations = mkHosts.mkHomeManagerHosts hosts;
  };
}
