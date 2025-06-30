{ ... }:
{
  imports = [
    ./boot.nix
    ./btrfs-maintenance.nix
    ./desktop.nix
    ./environment.nix
    ./networking.nix
    ./nix.nix
    ./nixos.nix
    ./nixos-options.nix
    ./nix-cache.nix
    ./nix-cache-key.nix
    ./systemd.nix
    ./traefik.nix
    ./virtualisation.nix
    ./zswap.nix
  ];
}
