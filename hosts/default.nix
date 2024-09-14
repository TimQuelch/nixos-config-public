{ nixpkgs, inputs }:
let
  configurePkgs = system: import nixpkgs {
    inherit system;
    config = {
      allowUnfree = true;
    };
    overlays = [
      (import ../pkgs)
    ];
  };
  mkNixOsConfig = {system, extraArgs, name, hardware, user, homeManagerModuleList, ...}:
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
  mkHomeManagerConfig = { pkgs, extraArgs, homeManagerModuleList, ... }:
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = extraArgs;
      modules = homeManagerModuleList;
    };
  mkHost = mk: args@{ name, hostname, system, user, inputs, ... }:
    let
      pkgs = configurePkgs system;
      extraArgs = { inherit pkgs inputs user hostname; };
      homeManagerModuleList = [
        ./home.nix
        ./${name}/home.nix
        inputs.sops-nix.homeManagerModules.sops
        ../modules/home
      ];
      common = { inherit pkgs inputs extraArgs homeManagerModuleList system; };
    in
      mk (args // common);
  mkHosts = mk: hosts:
    builtins.listToAttrs (
      map (args@{ name, ... }:
        let
          hostname = if builtins.hasAttr "hostname" args then args.hostname else name;
          user = if builtins.hasAttr "user" args then args.user else "timquelch";
        in
        { name = hostname; value = mkHost mk (args // { inherit hostname user inputs; }); })
      hosts
    );
in
{
  mkNixOsHosts = mkHosts mkNixOsConfig;
  mkHomeManagerHosts = mkHosts mkHomeManagerConfig;
}
