{
  nixpkgs,
  nixos-images,
  system,
}:
{
  iso =
    (nixpkgs.legacyPackages.${system}.nixos [
      ../../config/bootable.nix
      nixos-images.nixosModules.image-installer
    ]).config.system.build.isoImage;
}
