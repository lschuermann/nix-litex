pkgMeta:
{ lib
, buildPythonPackage
, litex
, pyyaml
, migen
, litex-boards
, litedram
, liteeth
, litespi
, litehyperbus
, liteiclink
}:

buildPythonPackage rec {
  pname = "litepcie";
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

  checkInputs = [
    litex-boards
    litedram
    liteeth
    litespi
    litehyperbus
    liteiclink
  ];

  doCheck = true;
}
