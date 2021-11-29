pkgMeta:
{ lib
, buildPythonPackage
, pythondata-software-compiler_rt
, pyserial
, migen
, requests
, colorama
, litedram
, pythondata-cpu-vexriscv
, runCommand
}:

buildPythonPackage rec {
  pname = "litex";
  version = pkgMeta.git_revision;

  src = builtins.fetchGit {
    url = "https://github.com/${pkgMeta.github_user}/${pkgMeta.github_repo}";
    rev = pkgMeta.git_revision;
  };

  propagatedBuildInputs = [
    # LLVM's compiler-rt data downloaded and importable as a python
    # package
    pythondata-software-compiler_rt

    pyserial
    migen
    requests
    colorama
  ];

  checkInputs = [
    litedram
    pythondata-cpu-vexriscv
  ];

  doCheck = true;
}
