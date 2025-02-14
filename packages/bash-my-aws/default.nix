{
  lib,
  stdenv,
  fetchFromGitHub,
  awscli2,
  jq,
  unixtools,
  bashInteractive,
  installShellFiles,
  makeWrapper,
}:
stdenv.mkDerivation {
  name = "bash-my-aws";

  src = fetchFromGitHub {
    owner = "bash-my-aws";
    repo = "bash-my-aws";
    rev = "d338b43cc215719c1853ec500c946db6b9caaa11";
    hash = "sha256-PR52T6XCrakQsBOJXf0PaYpYE5oMcIz5UDA4I9B7C38=";
  };

  nativeBuildInputs = [
    bashInteractive
    installShellFiles
    makeWrapper
  ];

  patches = [ ./0001-Update-paths-placeholders.patch ];

  buildPhase = ''
    runHook preBuild

    patchShebangs --build ./scripts/build
    patchShebangs --build ./scripts/build-completions
    patchShebangs --build ./scripts/build-docs

    ./scripts/build

    substituteAllInPlace ./aliases
    substituteAllInPlace ./functions
    substituteAllInPlace ./bin/bma

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -R . $out
    installShellCompletion --bash --name bash-my-aws.bash $out/bash_completion.sh
    runHook postInstall
  '';

  preCheck = "pushd $out";
  postCheck = "popd";

  postFixup = ''
    wrapProgram $out/bin/bma --prefix PATH : ${
      lib.makeBinPath [
        awscli2
        jq
        unixtools.column
        bashInteractive
      ]
    }
  '';
}
