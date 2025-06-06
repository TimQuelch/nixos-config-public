{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.modules.cloud;

  awsModule = lib.types.submodule {
    options = {
      enable = lib.mkEnableOption "aws tooling";
    };
  };

  azureModule = lib.types.submodule {
    options = {
      enable = lib.mkEnableOption "azure tooling";
      extensions = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [ ];
      };
    };
  };
in
{
  options.modules.cloud = {
    aws = lib.mkOption {
      type = awsModule;
      default = { };
    };
    azure = lib.mkOption {
      type = azureModule;
      default = { };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.aws.enable {
      home.packages = with pkgs; [
        awscli2
        bash-my-aws
        ssm-session-manager-plugin
      ];

      home.file.".aws/cli/alias".source = ./aws_aliases;

      programs.zsh = {
        # Before completionInit
        initContent = (lib.mkOrder 550 "eval $(bma-init)");

        completionInit = "complete -C '${pkgs.awscli2}/bin/aws_completer' aws";
      };
    })
    (lib.mkIf cfg.azure.enable {
      home.packages = [
        (pkgs.azure-cli.withExtensions cfg.azure.extensions)
      ];
    })
  ];
}
