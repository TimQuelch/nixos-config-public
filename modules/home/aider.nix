{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.modules.aider;
  updateEnvScript = pkgs.writeShellApplication {
    name = "update-anthropic-key-env";
    text = ''
      ENV_FILE="$HOME/.env"
      KEY_NAME="ANTHROPIC_API_KEY"
      NEW_VALUE=$(cat ${config.sops.secrets.anthropic_key.path})

      if [ ! -f "$ENV_FILE" ]; then
        echo "$KEY_NAME=$NEW_VALUE" > "$ENV_FILE"
      else
        if grep -q "^$KEY_NAME=" "$ENV_FILE"; then
          sed -i "s|^$KEY_NAME=.*|$KEY_NAME=$NEW_VALUE|" "$ENV_FILE"
        else
          echo "$KEY_NAME=$NEW_VALUE" >> "$ENV_FILE"
        fi
      fi
      chmod 600 "$ENV_FILE"
    '';
  };
in {
  options.modules.aider = { enable = mkEnableOption "aider configuration"; };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.aider-chat ];

    sops.secrets."anthropic_key" = { };

    systemd.user.services.update-anthropic-env = {
      Unit = {
        Description = "Update Anthropic API key in .env file";
        After = [ "sops-nix.service" ];
      };

      Service = {
        Type = "oneshot";
        ExecStart = "${lib.getExe updateEnvScript}";
      };

      Install = { WantedBy = [ "default.target" ]; };
    };
  };
}
