{ lib, pkgs, config, options, ... }:
let cfg = config.modules.git;
in {
  options.modules.git = { enable = lib.mkEnableOption "git config"; };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      userEmail = "tim@tquelch.com";
      userName = "Tim Quelch";
      aliases = { graph = "log --oneline --all --decorate --graph"; };
      extraConfig = {
        push = {
          default = "current";
          autoSetupRemote = true;
        };
        pull = { ff = "only"; };
        init = { defaultBranch = "main"; };
      };
      delta.enable = true;
    };
  };
}
