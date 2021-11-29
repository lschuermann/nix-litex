pkgMeta:
{ lib, buildPythonPackage, litex, pyyaml, migen }:

buildPythonPackage rec {
  pname = "litehyperbus";
  version = pkgMeta.git_revision;

  src = builtins.fetchGit {
    url = "https://github.com/${pkgMeta.github_user}/${pkgMeta.github_repo}";
    rev = pkgMeta.git_revision;
  };

  buildInputs = [
    litex
    pyyaml
    migen
  ];

  doCheck = true;
}
