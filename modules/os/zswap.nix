{ lib, config, pkgs, options, ... }:
let
  cfg = config.modules.os.zswap;
in {
  options.modules.os.zswap = {
    enable = lib.mkEnableOption "enable zswap";
  };

  config = lib.mkIf cfg.enable {
    systemd.services.zswap = {
      description = "Enable ZSwap, set to ZSTD and Z3FOLD";
      enable = true;
      wantedBy = [ "basic.target" ];
      path =  [ pkgs.bash ];
      serviceConfig = {
        ExecStart = ''${pkgs.bash}/bin/bash -c \
          'cd /sys/module/zswap/parameters && \
          echo 1 > enabled&& \
          echo zstd > compressor&& \
          echo z3fold > zpool'
        '';
        Type = "oneshot";
      };
    };
  };
}
