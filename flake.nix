{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ nixpkgs, flake-utils, ... }: flake-utils.lib.eachDefaultSystem (
    system:
      let
        # List of hosts to generate
        # `name` specifies which configuration to lookup
        # `hostname` defaults to name if not specified. lookup from env if we don't care
        # `hardware` specifies which hardware_configuration to lookup. ignored for home-manager
        hosts = [
          { name = "alpha"; hardware = "desktop"; }
          { name = "epsilon"; hardware = "laptop"; }
        ];
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
        };
        nixOsFilter = pkgs.lib.filter (h: builtins.hasAttr "hardware" h);
        mkHosts = import ./hosts { inherit nixpkgs pkgs inputs system; };
      in {
        packages = {
          # Make nixos configs for only hosts that have hardware associated
          nixosConfigurations = mkHosts.mkNixOsHosts (nixOsFilter hosts);
          # Make home-manager configs for all hosts
          homeConfigurations = mkHosts.mkHomeManagerHosts hosts;
        };
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [ sops age ];
        };
      }
    );
}
