pkgMeta:
{ lib, buildPythonPackage, fetchFromGitHub , litex
, liteiclink, migen, litex-boards, litescope, litedram }:

buildPythonPackage rec {
  pname = "liteeth";
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
    # Some of these are really only required because litex-boards
    # needs them for importing all targets in its __init__.py.
    liteiclink migen litex-boards litescope litedram
  ];

  doCheck = true;
}
