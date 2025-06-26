{ nixpkgs, system }:
let
  makeConfig =
    module:
    (import (nixpkgs + "/nixos/lib/eval-config.nix") {
      inherit system;
      modules = [
        module
        ../../config/bootable.nix
        (
          { config, ... }:
          {
            nixpkgs.hostPlatform = system;
            system.stateVersion = config.system.nixos.release;
          }
        )
      ];
    });

  bootableModules = (nixpkgs + "/nixos/modules/installer");

  netbootSys = makeConfig (bootableModules + "/netboot/netboot-minimal.nix");
  netbootConfig = netbootSys.config.system.build;

  isoConfig =
    (makeConfig (bootableModules + "/cd-dvd/installation-cd-minimal.nix")).config.system.build;
in
{
  netboot = netbootSys.pkgs.symlinkJoin {
    name = "netboot";
    paths = [
      netbootConfig.netbootRamdisk
      netbootConfig.kernel
    ];
    passthru = {
      kernelTarget = netbootConfig.pkgs.stdenv.hostPlatform.linux-kernel.target;
    };
  };

  iso = isoConfig.isoImage;
}
