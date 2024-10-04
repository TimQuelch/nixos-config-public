{ nixpkgs, pkgs, inputs, system }:
let
  mkNixOsConfig = { extraArgs, name, hardware, user, homeManagerModuleList, ...}:
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = extraArgs;
      modules = [
        ./configuration.nix
        ./${name}/configuration.nix
        ../hardware/${hardware}-hardware-configuration.nix
        inputs.home-manager.nixosModules.home-manager {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = extraArgs;
            users.${user} = {
              imports = homeManagerModuleList;
            };
          };
        }
        inputs.sops-nix.nixosModules.sops
        ../modules/os
      ];
    };
  mkHomeManagerConfig = { extraArgs, homeManagerModuleList, ... }:
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = extraArgs;
      modules = homeManagerModuleList;
    };
  mkHosts = mkHost: hosts:
    builtins.listToAttrs (
      map (args@{ name, ... }:
        let
          hostname = if builtins.hasAttr "hostname" args then args.hostname else name;
          user = if builtins.hasAttr "user" args then args.user else "timquelch";
          extraArgs = { inherit pkgs inputs user hostname; };
          homeManagerModuleList = [
            ./home.nix
            ./${name}/home.nix
            inputs.sops-nix.homeManagerModules.sops
            inputs.nix-index-database.hmModules.nix-index
            ../modules/home
          ];
          common = { inherit user hostname extraArgs homeManagerModuleList; };
        in
        { name = hostname; value = mkHost (args // common); })
      hosts
    );
in
{
  mkNixOsHosts = mkHosts mkNixOsConfig;
  mkHomeManagerHosts = mkHosts mkHomeManagerConfig;
}
