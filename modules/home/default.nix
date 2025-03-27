{ ... }:
{
  imports = [
    ./shell
    ./gui
    ./work
    ./ssh.nix
    ./emacs.nix
    ./email.nix
    ./git.nix
    ./dirs.nix
    ./aider.nix
    ./nix-shell-helper.nix
    ./latex.nix
  ];
}
