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
          "theta-boot" = lib.hm.dag.entryBefore ["default"] {
            host = "192.168.20.99";
            user = "root";
            port = 123;
            identitiesOnly = true;
            identityFile = config.sops.secrets."ssh_auth_keys/non_sk".path;
          };
          "default" = {
            host = "*";
            identitiesOnly = true;
            identityFile = config.sops.secrets."ssh_auth_keys/primary".path;
          };
        }
      );
    };

    sops.secrets = (
      builtins.listToAttrs (lib.mapCartesianProduct
        ({ name, suf }: {name = "ssh_auth_keys/${name}${suf}"; value={};})
        { name = github-keys; suf = ["" ".pub"];  }
      )
      //
      builtins.listToAttrs (lib.mapCartesianProduct
        ({ name, suf }: {
          name = "ssh_auth_keys/${name}${suf}";
          value.path = "${config.home.homeDirectory}/.ssh/${name}${suf}";
        })
        { name = [ "primary" "non_sk" ]; suf = ["" ".pub"];  }
      )
    );

    services.ssh-agent.enable = true;

    # Add the primary SSH key to the authorised keys file if it is not already there. Note that this
    # is somewhat impure because it will not remove the key if the key changes. An alternate
    # solution would be to link the authorized keys file to a file in the nix store, however this
    # would remove the ability to edit this file easily
    systemd.user.services.add-authorised-ssh-key = {
      Unit.Description = "Add primary ssh key to authorised_keys file";
      Install = {
        WantedBy = [ "sops-nix.service" ];
        After = [ "sops-nix.service" ];
      };
      Service = let
        keyPath = config.sops.secrets."ssh_auth_keys/primary.pub".path;
        authorizedKeysPath = "${config.home.homeDirectory}/.ssh/authorized_keys";
      in {
        Type = "oneshot";
        ExecStart = ''
          ${pkgs.bash}/bin/bash -c \
            "${pkgs.gnugrep}/bin/grep -q -f ${keyPath} ${authorizedKeysPath} \
             || cat ${keyPath} >> ${authorizedKeysPath}"
        '';
      };
    };
  };
}
