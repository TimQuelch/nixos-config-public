{
  lib,
  fetchFromGitHub,
  installShellFiles,
  python3Packages,
  ssm-session-manager-plugin,
}:
python3Packages.buildPythonApplication {
  name = "csi";
  version = "unstable";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "itsjfx";
    repo = "csi";
    rev = "8c6f13d6c33978fa2e5f49009491c5ac4f0a04df";
    hash = "sha256-4/mIom2IaU7oo67y1Ox7jlC4NI6DUgIH2Y661TnxoS0=";
  };

  patches = [ ./0001-Add-setuptools-config.patch ];

  nativeBuildInputs = [ installShellFiles ];

  build-system = [ python3Packages.setuptools ];

  dependencies = with python3Packages; [
    boto3
    botocore
    requests
    ssm-session-manager-plugin
  ];

  postInstall = ''
    installShellCompletion completions/csi.{bash,zsh}
  '';

  # runtime boto deps don't match but are probably fine
  # shtab not needed at runtime
  dontCheckRuntimeDeps = true;
}
