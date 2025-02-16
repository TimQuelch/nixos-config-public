{
  config,
  lib,
  pkgs,
  ...
}:
let
  modname = "nix-shell-helper";
  cfg = config.modules.${modname};
in
{
  options.modules.${modname} = {
    enable = lib.mkEnableOption modname;
    pinnedNixpkgsFlake = lib.mkOption {
      type = lib.types.str;
      default = "nixpkgs";
      description = "The nixpkgs flake to use";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      (pkgs.custom.nix-shell-helper.override { registry = cfg.pinnedNixpkgsFlake; })
    ];
  };
}
