{ isNixOs, hosts, nixpkgs, inputs }:
let
  mkHost = args@{ name, hardware, system, ... }:
    let
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
        overlays = [
          (import ../pkgs)
        ];
      };
      user = if builtins.hasAttr "user" args then args.user else "timquelch";
      hostname = if builtins.hasAttr "hostname" args then args.hostname else name;
      extraArgs = { inherit pkgs inputs user hostname; };
      homeManagerModules = [
        ./home.nix
        ./${name}/home.nix
      ];
    in
      if isNixOs then
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
                  imports = homeManagerModules;
                };
              };
            }
          ];
        }
      else
        inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = extraArgs;
          modules = homeManagerModules;
        };
in
builtins.listToAttrs (
  map (inputs@{ name, hostname ? null, ... }:
    { name = if isNull hostname then name else hostname; value = mkHost inputs; })
  hosts
)
