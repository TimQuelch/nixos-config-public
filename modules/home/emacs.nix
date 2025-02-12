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
  options.modules.emacs = { enable = mkEnableOption "emacs"; };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # for native comp
      binutils

      # fonts
      iosevka
      nerd-fonts.symbols-only

      # doom
      git
      ripgrep
      gnutls
      fd
      imagemagick
      zstd

      # spell check
      (aspellWithDicts (ds: with ds; [ en en-computers en-science ]))

      # org roam and lookup
      sqlite

      # to compile vterm
      cmake

      # SOPs/Age
      age
      sops

      # treemacs git
      python3

      # nix mode
      nixfmt-classic

      # utils
      shellcheck

      # for copilot
      nodejs

      # lsps
      basedpyright
      ruff
      typescript-language-server
      clang-tools
      rust-analyzer
      gopls
      yaml-language-server

      # formatters
      black
      clang-tools
      cmake-format
      dprint
      nixfmt-classic
      nodePackages.prettier
      shfmt
      stylua
      rustfmt

      # My helpers
      doom-bin
      init-emacs-config-bin
    ];

    programs.emacs = {
      enable = true;
      package = pkgs.emacs30;
      extraPackages = epkgs: [ epkgs.vterm ];
    };
    services.emacs = {
      enable = true;
      client.enable = true;
    };
  };
}
