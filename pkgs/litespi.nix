pkgMeta:
{ lib, buildPythonPackage, litex }:

buildPythonPackage rec {
  pname = "litespi";
  version = pkgMeta.git_revision;

  src = builtins.fetchGit {
    url = "https://github.com/${pkgMeta.github_user}/${pkgMeta.github_repo}";
    rev = pkgMeta.git_revision;
  };

  buildInputs = [
    litex
  ];

  doCheck = true;
}
