pkgMeta:
{ lib, buildPythonPackage, fetchFromGitHub, pkgsCross, litex, litex-boards, liteiclink, litedram
, liteeth, litepcie, litespi, litehyperbus, pythondata-cpu-vexriscv }:

buildPythonPackage rec {
  pname = "litescope" ;
  version = pkgMeta.git_revision;

  src = fetchFromGitHub {
    owner = pkgMeta.github_user;
    repo = pkgMeta.github_repo;
    rev = pkgMeta.git_revision;
    sha256 = pkgMeta.github_archive_nix_hash;
  };

  buildInputs = [
    litex
  ];

  checkInputs = [
    litex litex-boards liteiclink litedram liteeth litepcie litespi litehyperbus pythondata-cpu-vexriscv
    pkgsCross.riscv64.buildPackages.gcc
  ];

  doCheck = true;
}
