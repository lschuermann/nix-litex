pkgMeta:
{ lib
, buildPythonPackage
, pkgsCross
, litex
, litex-boards
, liteiclink
, litedram
, liteeth
, litepcie
, litespi
, litehyperbus
, pythondata-cpu-vexriscv
}:

buildPythonPackage rec {
  pname = "litescope";
  version = pkgMeta.git_revision;

  src = builtins.fetchGit {
    url = "https://github.com/${pkgMeta.github_user}/${pkgMeta.github_repo}";
    rev = pkgMeta.git_revision;
  };

  buildInputs = [
    litex
  ];

  checkInputs = [
    litex
    litex-boards
    liteiclink
    litedram
    liteeth
    litepcie
    litespi
    litehyperbus
    pythondata-cpu-vexriscv
    pkgsCross.riscv64.buildPackages.gcc
  ];

  doCheck = true;
}
