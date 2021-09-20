pkgMeta:
{ lib
, buildPythonPackage
, fetchFromGitHub
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

  src = fetchFromGitHub {
    owner = pkgMeta.github_user;
    repo = pkgMeta.github_repo;
    rev = pkgMeta.git_revision;
    sha256 = pkgMeta.github_archive_nix_hash;
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
