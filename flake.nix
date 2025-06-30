{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixos-images.url = "github:nix-community/nixos-images";
    nixos-images.inputs.nixos-stable.follows = "nixpkgs"; # unused because only the module is used
    nixos-images.inputs.nixos-unstable.follows = "nixpkgs"; # unused because only the module is used
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    hyprswitch.url = "github:H3rmt/hyprswitch";
    hyprswitch.inputs.nixpkgs.follows = "nixpkgs";
    pre-commit-hooks.url = "github:cachix/git-hooks.nix";
    pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      nixpkgs,
      flake-utils,
      nixos-images,
      pre-commit-hooks,
      ...
    }:
    let
      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
          overlays = (import ./overlays);
        };

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
        {
          name = "beta";
        }
      ];
    in

    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = mkPkgs system;
        bootables = import ./packages/bootables { inherit nixpkgs nixos-images system; };

        preCommit = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks.nixfmt-rfc-style.enable = true;
        };
      in
      {
        packages = pkgs.custom // {
          inherit (pkgs) mujmap aider-chat;
          inherit (bootables) iso;
        };
        devShells.default = pkgs.mkShell {
          inherit (preCommit) shellHook;
          buildInputs = preCommit.enabledPackages;
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
    )
    // flake-utils.lib.eachDefaultSystemPassThrough (
      system:
      let
        pkgs = mkPkgs system;
        mkHosts = import ./hosts { inherit nixpkgs pkgs inputs; };
      in
      {
        nixosConfigurations = mkHosts.mkNixOsHosts hosts;
        homeConfigurations = mkHosts.mkHomeManagerHosts hosts;
      }
    );
}
