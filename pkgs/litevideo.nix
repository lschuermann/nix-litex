pkgMeta:
{ buildPythonPackage, litex, migen }:

buildPythonPackage rec {
  pname = "litevideo";
  version = pkgMeta.git_revision;

  src = builtins.fetchGit {
    url = "https://github.com/${pkgMeta.github_user}/${pkgMeta.github_repo}";
    rev = pkgMeta.git_revision;
  };

  buildInputs = [
    litex
    migen
  ];

  doCheck = false;
}
