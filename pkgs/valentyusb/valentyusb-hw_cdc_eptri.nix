pkgMeta:
{ lib, buildPythonPackage, fetchFromGitHub, litex, cocotb, sigrok-cli, verilog }:

buildPythonPackage rec {
  pname = "valentyusb-hw_cdc_eptri";
  version = pkgMeta.git_revision;

  src = fetchFromGitHub {
    owner = pkgMeta.github_user;
    repo = pkgMeta.github_repo;
    rev = pkgMeta.git_revision;
    sha256 = pkgMeta.github_archive_nix_hash;
  };

  patches = [
    ./0001-Add-setup.py.patch
    ./0002-Add-__init__.py-files-to-modules.patch
  ];

  buildInputs = [
    litex
  ];

  checkInputs = [
    cocotb
    sigrok-cli
    verilog
  ];

  # Checks are currently broken. It looks like upstream LiteX has
  # advanced too far and valentyusb (or the respective fork with
  # hw_cdc_eptri branch) hasn't cought up yet. This could potentially
  # mean that building boards which depend on valentyusb could fail.
  doCheck = false;
}
