{ lib, config, pkgs, options, ... }:
let
  cfg = config.modules.email;
  inherit (lib) mkEnableOption mkIf;
in {
  options.modules.email = { enable = mkEnableOption "email"; };

  config = mkIf cfg.enable {
    sops.secrets.fastmail_token = { };

    accounts.email.accounts.personal = {
      primary = true;
      address = "tim@tquelch.com";
      realName = "Tim Quelch";
      flavor = "fastmail.com";
      passwordCommand = "cat ${config.sops.secrets.fastmail_token.path}";
      notmuch.enable = true;
      mujmap.enable = true;
    };

    programs.notmuch.enable = true;
    programs.mujmap.enable = true;
  };
}
