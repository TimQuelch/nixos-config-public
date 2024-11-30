{ ... }: {
  imports = [
    ./shell
    ./work
    ./ssh.nix
    ./hyprland.nix
    ./emacs.nix
    ./email.nix
    ./git.nix
  ];
}
