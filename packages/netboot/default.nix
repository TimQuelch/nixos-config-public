{ nixpkgs, system }:
let
  nixosConfig = import (nixpkgs + "/nixos/lib/eval-config.nix") {
    inherit system;
    modules = [
      ../../config/bootable.nix
      (
        { config, ... }:
        {
          nixpkgs.hostPlatform = system;
          system.stateVersion = config.system.nixos.release;
        }
      )
    ];
  };
  build = nixosConfig.config.system.build;
in
nixosConfig.pkgs.symlinkJoin {
  name = "netboot";

  paths = [
    build.netbootRamdisk
    build.kernel
  ];

  passthru = {
    kernelTarget = nixosConfig.pkgs.stdenv.hostPlatform.linux-kernel.target;
  };
}
