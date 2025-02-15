{ ... }:
{
  imports = [
    ./zswap.nix
    ./nixos-options.nix
    ./btrfs-maintenance.nix
    ./traefik.nix
    ./nix-cache.nix
  ];
}
