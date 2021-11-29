pkgMeta:
{ lib, buildPythonPackage, litex }:

buildPythonPackage rec {
  pname = "litesdcard";
  version = pkgMeta.git_revision;

  src = builtins.fetchGit {
    url = "https://github.com/${pkgMeta.github_user}/${pkgMeta.github_repo}";
    rev = pkgMeta.git_revision;
  };

  prePatch = "touch litesdcard/frontend/__init__.py";

  buildInputs = [
    litex
  ];

  doCheck = true;
}
