{ lib, config, pkgs, options, ... }:
let
  cfg = config.modules.shell.fzf-tab-completion;
in {
  options.modules.shell.fzf-tab-completion = {
    enable = lib.mkEnableOption "fuzzy tab completion";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      fzf
      gawk
      gnugrep
      gnused
      coreutils
      custom.fzf-tab-completion
    ];

    programs.zsh.initExtra = ''
      source ${pkgs.custom.fzf-tab-completion}/zsh/fzf-zsh-completion.sh
    '';
  };
}
