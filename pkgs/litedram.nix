pkgMeta:
{ lib
, pkgsCross
, gnumake
, libevent
, zlib
, pandas
, numpy
, matplotlib
, migen
, buildPythonPackage
, litex
, pytest
, pyyaml
, pexpect
, pythondata-cpu-serv
, pythondata-cpu-vexriscv
, litescope
, pythondata-misc-tapcfg
, litex-boards
, liteeth
, liteiclink
, litepcie
, verilator
, json_c
, zeromq
}:

buildPythonPackage rec {
  pname = "litedram";
  version = pkgMeta.git_revision;

  src = builtins.fetchGit {
    url = "https://github.com/${pkgMeta.github_user}/${pkgMeta.github_repo}";
    rev = pkgMeta.git_revision;
  };

  buildInputs = [
    litex
    pyyaml
    migen
  ];

  checkPhase = ''
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

    # TestExamples::test_genesys2 currently overruns the BIOS ROM
    # size, so deselect this test
    pytest -v -k 'not test_genesys2' test/

    # Expect the deselected test_genesys2 test to fail
    ! pytest -v -k 'test_genesys2' test/test_examples.py
  '';

  checkInputs = [
    # For test summary
    pandas
    numpy
    matplotlib

    # Proper check inputs. Some of these are really only required
    # because litex-boards needs them for importing all targets in its
    # __init__.py.
    litex
    pytest
    pyyaml
    pexpect
    pythondata-cpu-serv
    pythondata-cpu-vexriscv
    litescope
    pythondata-misc-tapcfg
    litex-boards
    liteeth
    liteiclink
    litepcie

    # For running the litex_sim (part of the dependencies for that are
    # already listed above). The gcc will pull in various libraries,
    # as this is not a full stdenv in the checkPhase.
    verilator
    gnumake
    libevent.dev
    json_c
    zlib
    zeromq

    # It doesn't really matter which cross-compilation toolchain is
    # used here. This choice seems to be built by Hydra so that should
    # be the fastest one to have available on most systems.
    pkgsCross.riscv64.buildPackages.gcc
  ];

  doCheck = true;
}
