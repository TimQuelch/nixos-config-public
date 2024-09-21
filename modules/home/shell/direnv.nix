{ lib, config, options, ... }:
let
  cfg = config.modules.shell.direnv;
in {
  options.modules.shell.direnv = {
    enable = lib.mkEnableOption "direnv configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      # Put cached shells in the cache dir
      stdlib = ''
        declare -A direnv_layout_dirs
        direnv_layout_dir() {
            local hash path
            echo "''${direnv_layout_dirs[$PWD]:=$(
                hash="$(sha1sum - <<< "$PWD" | head -c40)"
                path="''${PWD//[^a-zA-Z0-9]/-}"
                echo "${config.xdg.cacheHome}/direnv/layouts/''${hash}''${path}"
            )}"
        }
      ''  ;
    };
  };
}
