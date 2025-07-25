{
  nixpkgs,
  pkgs,
  inputs,
}:
let
  mkRebuilder =
    builder:
    pkgs.writeShellApplication {
      name = "nr";
      text = ''
        ${builder} switch --flake "$HOME/nixos-config#$(${pkgs.hostname}/bin/hostname)-${pkgs.system}" "$@"
      '';
    };
  rebuildNixosConfig = mkRebuilder "sudo nixos-rebuild";
  rebuildHomeManagerConfig = mkRebuilder "home-manager";
  pathIfExists = path: nixpkgs.lib.optionals (builtins.pathExists path) [ path ];
  mkNixOsConfig =
    {
      extraArgs,
      name,
      user,
      homeManagerModuleList,
      hardware ? "",
      ...
    }:
    let
      extraArgs' = extraArgs // {
        rebuild = rebuildNixosConfig;
      };
    in
    nixpkgs.lib.nixosSystem {
      specialArgs = extraArgs';
      modules =
        [
          # nixpkgs.nixosModules.readOnlyPkgs # TODO conflicts with facter modules
          inputs.home-manager.nixosModules.home-manager
          inputs.sops-nix.nixosModules.sops
          inputs.disko.nixosModules.disko
          inputs.nixos-facter-modules.nixosModules.facter
          ../modules/os
          (
            { lib, ... }:
            {
              # use the already customised nixpkgs
              nixpkgs.pkgs = pkgs;

              # use facter to handle hardware configuration if we've generated a report
              facter = lib.mkIf (builtins.pathExists ./${name}/facter.json) {
                reportPath = ./${name}/facter.json;
              };

              # base global home manager config
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = extraArgs';
                users.${user} = {
                  imports = homeManagerModuleList;
                };
              };
            }
          )
        ]
        ++ (pathIfExists ./${name}/configuration.nix)
        ++ (pathIfExists ../hardware/${hardware}-hardware-configuration.nix);
    };
  mkHomeManagerConfig =
    { extraArgs, homeManagerModuleList, ... }:
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = extraArgs // {
        rebuild = rebuildHomeManagerConfig;
      };
      modules = homeManagerModuleList;
    };
  mkHosts =
    mkHost: hosts:
    builtins.listToAttrs (
      map (
        args@{ name, ... }:
        let
          hostname = if builtins.hasAttr "hostname" args then args.hostname else name;
          user = if builtins.hasAttr "user" args then args.user else "timquelch";
          extraArgs = {
            inherit
              inputs
              user
              hostname
              nixpkgs
              ;
          };
          homeManagerModuleList = [
            ../config/home.nix
            ../modules/home
            inputs.sops-nix.homeManagerModules.sops
            inputs.nix-index-database.hmModules.nix-index
            inputs.hyprswitch.homeModules.hyprshell
          ] ++ (pathIfExists ./${name}/home.nix);
          common = {
            inherit
              user
              hostname
              extraArgs
              homeManagerModuleList
              ;
          };
        in
        {
          name = "${hostname}-${pkgs.system}";
          value = mkHost (args // common);
        }
      ) hosts
    );
in
{
  mkNixOsHosts = mkHosts mkNixOsConfig;
  mkHomeManagerHosts = mkHosts mkHomeManagerConfig;
}
