pkgMeta: doChecks: { lib, fetchFromGitHub, python3Packages, litex }:

with python3Packages;

buildPythonPackage rec {
  pname = "litesdcard" + (lib.optionalString (!doChecks) "-unchecked");
  version = pkgMeta.git_revision;

  src = fetchFromGitHub {
    owner = pkgMeta.github_user;
    repo = pkgMeta.github_repo;
    rev = pkgMeta.git_revision;
    sha256 = pkgMeta.github_archive_nix_hash;
  };

  prePatch = "touch litesdcard/frontend/__init__.py";

  buildInputs = [
    litex
  ];

  doCheck = doChecks;
}
