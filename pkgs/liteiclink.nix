pkgMeta:
{ lib, buildPythonPackage, litex, migen, pytest, liteeth }:

buildPythonPackage rec {
  pname = "liteiclink";
  version = pkgMeta.git_revision;

  src = builtins.fetchGit {
    url = "https://github.com/${pkgMeta.github_user}/${pkgMeta.github_repo}";
    rev = pkgMeta.git_revision;
  };

  buildInputs = [
    litex
    migen
  ];

  doCheck = true;

  # For more information on why this hack is needed, see the
  # `pythonCheckInputsMagic.nix` file.
  ${import ./pythonCheckInputsMagic.nix lib buildPythonPackage} = [
    pytest
    liteeth
  ];

  checkPhase = ''
    pytest -v test/
  '';
}
