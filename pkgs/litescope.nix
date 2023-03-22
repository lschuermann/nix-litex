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

  # For more information on why this hack is needed, see the
  # `pythonCheckInputsMagic.nix` file.
  ${import ./pythonCheckInputsMagic.nix lib buildPythonPackage} = [
    litex
    litex-boards
    liteiclink
    litedram
    liteeth
    litepcie
    litespi
    litehyperbus
    pythondata-cpu-vexriscv
    pkgsCross.riscv64-embedded.buildPackages.gcc
  ];

  doCheck = true;
}
