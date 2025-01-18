{ lib, pkgs, config, options, ... }:
let
  cfg = config.modules.shell.zsh;
  customFzfCompletionDir = pkgs.fetchFromGitHub {
    owner = "lincheney";
    repo = "fzf-tab-completion";
    rev = "11122590127ab62c51dd4bbfd0d432cee30f9984";
    sha256 = "sha256-ds+GgCTXXavaELCy0MxAGHTPp2MFoFohm/gPkQCRuXU=";
  };
in {
  options.modules.shell.zsh = {
    enable = lib.mkEnableOption "zsh configs";
    customFzfTabCompletion = lib.mkOption {
      description = "Whether to enable custom fzf tab completion";
      type = lib.types.bool;
      default = true;
      example = false;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      autocd = true;
      dotDir = ".config/zsh"; # ideally this would be xdg.configHome but that gives an absolute path
      syntaxHighlighting.enable = true;
      plugins = [
        {
          name = "powerlevel10k";
          src = pkgs.zsh-powerlevel10k;
          file = "/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
        }
        {
          name = "powerlevel10k-config";
          src = ./plugins;
          file = "p10k.zsh";
        }
      ];
      completionInit = ''
        autoload bashcompinit && bashcompinit
        autoload -Uz compinit && compinit
        complete -C '${pkgs.awscli2}/bin/aws_completer' aws
      '';
      # Do this here instead of in a plugin so that it this config happens after
      # the fzf zsh eval. We want this to supercede it
      initExtra = (lib.optionalString cfg.customFzfTabCompletion ''
        source ${customFzfCompletionDir}/zsh/fzf-zsh-completion.sh
      '') + ''
        autoload -z edit-command-line
        zle -N edit-command-line
        bindkey "^X^E" edit-command-line
      '';
      history = {
        ignoreDups = true;
        ignoreSpace = true;
        ignorePatterns = [ "cd" "z" "exit" "pwd" "ls" ];
        save = 100000;
        size = 100000;
        path = "${config.xdg.dataHome}/zsh/zsh_history";
      };
    };

    programs.z-lua = {
      enable = true;
      enableZshIntegration = true;
      options = [ "enhanced" "once" "fzf" ];
    };

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
