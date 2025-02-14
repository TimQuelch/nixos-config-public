{
  writeShellApplication,
  registry ? "nixpkgs",
}:
writeShellApplication {
  name = "ns";
  text = ''
    if [ $# -eq 0 ]; then
      echo "Usage: ns package1 [package2 ...]"
      exit 1
    fi

    declare -a packages=()
    declare -a options=()

    for arg in "$@"; do
      if [[ "$arg" == --* ]]; then
        options+=("$arg")
      else
        packages+=("${registry}#$arg")
      fi
    done

    exec nix shell "''${packages[@]}" "''${options[@]}"
  '';
}
