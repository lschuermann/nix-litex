pkgMeta:
{ buildPythonPackage, fetchFromGitHub, litex, migen }:

buildPythonPackage rec {
  pname = "litevideo";
  version = pkgMeta.git_revision;

  src = fetchFromGitHub {
    owner = pkgMeta.github_user;
    repo = pkgMeta.github_repo;
    rev = pkgMeta.git_revision;
    sha256 = pkgMeta.github_archive_nix_hash;
  };

  buildInputs = [
    litex
    migen
  ];

  doCheck = false;
}
