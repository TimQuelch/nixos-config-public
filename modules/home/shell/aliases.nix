{ lib, config, options, ... }:
let cfg = config.modules.shell.aliases;
in {
  options.modules.shell.aliases.enable = lib.mkEnableOption "aliases" // {
    default = true;
  };

  config =
    lib.mkIf cfg.enable { home.shellAliases = { ls = "ls --color=auto"; }; };
}
