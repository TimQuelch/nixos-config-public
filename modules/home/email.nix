{ lib, config, pkgs, options, inputs, system, ... }:
let
  cfg = config.modules.email;
  inherit (lib) mkEnableOption mkIf;
in {
  options.modules.email = { enable = mkEnableOption "email"; };

  config = mkIf cfg.enable {
    accounts.email.accounts.personal = {
      primary = true;
      address = "tim@tquelch.com";
      realName = "Tim Quelch";
      flavor = "fastmail.com";
      passwordCommand = "cat /tmp/token";
      notmuch.enable = true;
      mujmap.enable = true;
    };

    programs.notmuch.enable = true;
    programs.mujmap.enable = true;
  };
}
