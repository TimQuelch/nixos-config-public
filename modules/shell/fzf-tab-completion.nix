{ lib, config, pkgs, self, system, options, ... }:
let
  mypkgs = self.packages.${system};
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
    ];

    programs.zsh.initExtra = ''
      source ${mypkgs.fzf-tab-completion}/zsh/fzf-zsh-completion.sh
    '';
  };
}
