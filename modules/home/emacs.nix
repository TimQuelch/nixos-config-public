{ lib, config, pkgs, options, ... }:
let
  cfg = config.modules.emacs;

  doom-bin = pkgs.writeShellApplication {
    name = "doom";
    text = ''
      "$HOME"/.emacs.d/bin/doom "$@"
    '';
  };
  init-emacs-config-bin = pkgs.writeShellApplication {
    name = "init-emacs-config";
    runtimeInputs = [ pkgs.git doom-bin ];
    text = ''
      doomdir="$HOME/.doom.d"
      emacsdir="$HOME/.emacs.d"
      if [ ! -d "$emacsdir" ]; then
        git clone https://github.com/doomemacs/doomemacs.git "$emacsdir"
      fi
      if [ ! -d "$doomdir" ]; then
        # Clone from https but change the push url to ssh
        git clone https://github.com/TimQuelch/emacs.d "$doomdir"
        pushd "$doomdir"
        git remote set-url --push origin git@github.com:TimQuelch/emacs.d
        popd
      fi
      doom sync
    '';
  };

  inherit (lib) mkEnableOption mkIf;
in {
  options.modules.emacs = {
    enable = mkEnableOption "emacs";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      git
      fd
      findutils
      ripgrep
      fzf
      iosevka
      sops    # sops global mode
      cmake   # to compile vterm
      doom-bin
      init-emacs-config-bin
    ];

    programs.emacs = {
      enable = true;
      package = pkgs.emacs;
    };
    services.emacs = {
      enable = true;
      client.enable = true;
    };
  };
}
