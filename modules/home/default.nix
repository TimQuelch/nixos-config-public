{ ... }: {
  imports = [
    ./shell
    ./gui
    ./work
    ./ssh.nix
    ./emacs.nix
    ./email.nix
    ./git.nix
  ];
}
