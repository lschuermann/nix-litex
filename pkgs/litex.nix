pkgMeta:
{ lib, fetchFromGitHub, buildPythonPackage, pythondata-software-compiler_rt
, pyserial, migen, requests, colorama, litedram, pythondata-cpu-vexriscv
, runCommand }:

buildPythonPackage rec {
  pname = "litex";
  version = pkgMeta.git_revision;

  src = fetchFromGitHub {
    owner = pkgMeta.github_user;
    repo = pkgMeta.github_repo;
    rev = pkgMeta.git_revision;
    sha256 = pkgMeta.github_archive_nix_hash;
  };

  propagatedBuildInputs = [
    # LLVM's compiler-rt data downloaded and importable as a python
    # package
    pythondata-software-compiler_rt

    pyserial migen requests colorama
  ];

  checkInputs = [
    litedram pythondata-cpu-vexriscv
  ];

  doCheck = true;
}
