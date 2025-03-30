{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.aider;

  updateAnthropicEnv = pkgs.writeShellApplication {
    name = "update-anthropic-env";
    runtimeInputs = [
      pkgs.gnugrep
      pkgs.gnused
    ];
    text = ''
      ENV_FILE="$HOME/.env"
      KEY_NAME="ANTHROPIC_API_KEY"
      NEW_VALUE=$(cat ${config.sops.secrets.anthropic_key.path})

      if [ ! -f "$ENV_FILE" ]; then
        echo "Creating new file '$ENV_FILE' with anthropic key"
        echo "$KEY_NAME=$NEW_VALUE" > "$ENV_FILE"
        chmod 600 "$ENV_FILE"
      else
        if grep -q "^$KEY_NAME=" "$ENV_FILE"; then
          echo "Updating existing key in '$ENV_FILE' with anthropic key"
          sed -i "s|^$KEY_NAME=.*|$KEY_NAME=$NEW_VALUE|" "$ENV_FILE"
        else
          echo "Creating new key in '$ENV_FILE' with anthropic key"
          echo "$KEY_NAME=$NEW_VALUE" >> "$ENV_FILE"
        fi
      fi
    '';
  };
in
{
  options.modules.aider = {
    enable = lib.mkEnableOption "aider configuration";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.aider-chat;
      description = "The aider package to use";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    sops.secrets."anthropic_key" = { };

    home.file.".aider.conf.yml" = {
      text = ''
        model: anthropic/claude-3-7-sonnet-20250219
        weak-model: anthropic/claude-3-5-haiku-20241022
        cache-prompts: true
        stream: false
        dark-mode: true
        attribute-author: false
        attribute-committer: false
      '';
    };

    systemd.user.services.update-anthropic-env = {
      Unit = {
        Description = "anthropic env activation";
        After = [ "sops-nix.service" ];
        Wants = [ "sops-nix.service" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = lib.getExe updateAnthropicEnv;
      };
      Install.WantedBy = [ "default.target" ];
    };
  };
}
