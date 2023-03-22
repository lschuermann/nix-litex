pkgMeta:
{ lib
, writeText
, buildPythonPackage
, fetchpatch
, pythondata-software-compiler_rt
, pythondata-software-picolibc
, pythondata-cpu-vexriscv
, pythondata-cpu-vexriscv_smp
, pythondata-cpu-serv
, pythondata-misc-tapcfg
, pyserial
, migen
, requests
, colorama
, litedram
, liteeth
, liteiclink
, litescope
, packaging
, pytest
, pexpect
, meson
, ninja
, pkgsCross
, verilator
, libevent
, json_c
, zlib
, zeromq
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

    # libc for the LiteX BIOS
    pythondata-software-picolibc

    # BIOS build tools. Must be propagated because LiteX will require
    # them to be in PATH when building any SoC with BIOS.
    meson
    ninja

    pyserial
    migen
    requests
    colorama
    packaging
  ];

  # For more information on why this hack is needed, see the
  # `pythonCheckInputsMagic.nix` file.
  ${import ../pythonCheckInputsMagic.nix lib buildPythonPackage} = [
    litedram
    liteeth
    liteiclink
    litescope
    pythondata-cpu-vexriscv
    pythondata-cpu-vexriscv_smp
    pythondata-cpu-serv
    pythondata-misc-tapcfg
    pkgsCross.riscv64-embedded.buildPackages.gcc
    pexpect
    pytest

    # For Verilator simulation
    verilator
    libevent
    json_c
    zlib
    zeromq
  ];

  checkPhase = ''
    # The tests will try to execute the litex_sim command, which is
    # installed as part of this package. While $out is already added
    # to PYTHONPATH here, it isn't yet added to PATH.
    export PATH="$out/bin:$PATH"

    # This needs to be exported manually because checkInputs doesn't
    # propagate to these variables
    export NIX_CFLAGS_COMPILE=" \
      -isystem ${libevent.dev}/include \
      -isystem ${json_c.dev}/include \
      -isystem ${zlib.dev}/include \
      -isystem ${zeromq}/include \
      $NIX_CFLAGS_COMPILE"
    export NIX_LDFLAGS=" \
      -L${libevent}/lib \
      -L${json_c}/lib \
      -L${zlib}/lib \
      -L${zeromq}/lib \
      $NIX_LDFLAGS"

    # Only test CPU variants we actually package and want to support
    # as part of this repository. Others are disabled by the following
    # patch:
    patch -p1 < ${writeText "disable-litex-test-cpus.patch" (
      builtins.readFile ./0001-Disable-LiteX-CPU-tests-for-select-CPUs.patch)}

    pytest -v test/
  '';

  doCheck = true;
}
