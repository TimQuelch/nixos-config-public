{ lib, config, pkgs, options, ... }:
let
  cfg = config.modules.ssh;
  github-keys = [ "primary_github" "client_github" ];
  github-match-blocks = builtins.listToAttrs (map (host: {
    name = host;
    value = lib.hm.dag.entryBefore   ["default_github"] {
      host = host;
      hostname = "github.com";
      user = "git";
      identitiesOnly = true;
      identityFile = config.sops.secrets."ssh_auth_keys/${host}".path;
    };
  }) github-keys);
  inherit (lib) mkEnableOption mkOption mkIf types;
in {
  options.modules.ssh = {
    enable = mkEnableOption "configure ssh client";
  };

  config = mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      addKeysToAgent = "yes";
      matchBlocks = (github-match-blocks //
        {
          "default_github" = lib.hm.dag.entryBefore ["default"] {
            host = "github.com";
            user = "git";
            identitiesOnly = true;
            identityFile = config.sops.secrets."ssh_auth_keys/primary_github".path;
          };
          "default" = {
            host = "*";
            identitiesOnly = true;
            identityFile = config.sops.secrets."ssh_auth_keys/primary".path;
          };
        }
      );
    };

    sops.secrets = builtins.listToAttrs (lib.mapCartesianProduct
      ({ name, suf }: {name = "ssh_auth_keys/${name}${suf}"; value={};})
      { name = github-keys ++ [ "primary" ]; suf = ["" ".pub"];  }
    );

    services.ssh-agent.enable = true;
  };
}
