{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.aider;
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

    home.activation.anthropic-env = lib.hm.dag.entryAfter [ "sops-nix" ] ''
      ENV_FILE="$HOME/.env"
      KEY_NAME="ANTHROPIC_API_KEY"
      NEW_VALUE=$(cat ${config.sops.secrets.anthropic_key.path})

      if [ ! -f "$ENV_FILE" ]; then
        run echo "$KEY_NAME=$NEW_VALUE" > "$ENV_FILE"
      else
        if grep -q "^$KEY_NAME=" "$ENV_FILE"; then
          run sed -i "s|^$KEY_NAME=.*|$KEY_NAME=$NEW_VALUE|" "$ENV_FILE"
        else
          run echo "$KEY_NAME=$NEW_VALUE" >> "$ENV_FILE"
        fi
      fi
      run chmod 600 "$ENV_FILE"
    '';
  };
}
