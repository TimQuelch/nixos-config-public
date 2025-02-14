{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-bash-my-aws.url = "github:TimQuelch/nixpkgs/bash-my-aws";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    hyprswitch.url = "github:H3rmt/hyprswitch";
    hyprswitch.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      nixpkgs,
      nixpkgs-bash-my-aws,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        consts =
          if (builtins.pathExists ./secrets/constants.nix) then import ./secrets/constants.nix else { };
        constOrDefault = name: default: if (builtins.hasAttr name consts) then consts.${name} else default;
        # List of hosts to generate
        # `name` specifies which configuration to lookup
        # `hostname` defaults to name if not specified. lookup from env if we don't care
        # `hardware` specifies which hardware_configuration to lookup. ignored for home-manager
        hosts = [
          {
            name = "alpha";
            hardware = "desktop";
          }
          {
            name = "epsilon";
            hardware = "laptop";
          }
          {
            name = "work-laptop";
            hostname = constOrDefault "workHostname" "work-laptop";
          }
        ];
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
          overlays = (import ./overlays) ++ [
            inputs.hyprswitch.overlays.default
            (final: prev: {
              bash-my-aws = nixpkgs-bash-my-aws.legacyPackages.${final.system}.bash-my-aws;
            })
          ];
        };
        nixOsFilter = pkgs.lib.filter (h: builtins.hasAttr "hardware" h);
        mkHosts = import ./hosts { inherit nixpkgs pkgs inputs; };
      in
      {
        packages = {
          # Make nixos configs for only hosts that have hardware associated
          nixosConfigurations = mkHosts.mkNixOsHosts (nixOsFilter hosts);
          # Make home-manager configs for all hosts
          homeConfigurations = mkHosts.mkHomeManagerHosts hosts;
        } // pkgs.custom;
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            sops
            age
            nixfmt-rfc-style
            go
            gopls
            gotools
            golangci-lint
            git-filter-repo
          ];
        };
      }
    );
}
