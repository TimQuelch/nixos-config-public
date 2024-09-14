{ lib, config, options, ... }:
let
  cfg = config.modules.shell.zsh;
in {
  options.modules.shell.zsh = {
    enable = lib.mkEnableOption "zsh configs";
  };

  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      oh-my-zsh = {
        enable = true;
        theme = "intheloop";
        plugins = [
        "colored-man-pages"
        "fd"
        "fzf"
        "ripgrep"
        "sudo"
        ];
      };
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
