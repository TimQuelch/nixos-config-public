{ lib, pkgs, config, options, ... }:
let
  cfg = config.modules.shell.zsh;
in {
  options.modules.shell.zsh = {
    enable = lib.mkEnableOption "zsh configs";
  };

  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      initExtra = ''
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
        source ${./p10k.zsh}
      '';
      history = {
        ignoreDups = true;
        ignoreSpace = true;
        ignorePatterns = [ "cd" "z" "exit" "pwd" "ls" ];
        save = 100000 ;
        size = 100000;
      };
    };

    programs.z-lua = {
      enable = true;
      enableZshIntegration = true;
      options = [ "enhanced" "once" "fzf" ];
    };
  };
}
