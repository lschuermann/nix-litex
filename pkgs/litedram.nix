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

    # The following tests are broken on more recent versions of Migen
    # (e.g., unstable-2022-09-02 as shipped with NixOS 23.11, rev
    # 639e66f4f45343). This issue will need to be fixed upstream in
    # either LiteX or Migen.
    pytest -v test/ -k "\
      not test_sim_serializer_16 \
      and not test_sim_serializer_16_phase90 \
      and not test_sim_serializer_16_phase90_check0 \
      and not test_sim_serializer_16_phase90_gen0 \
      and not test_sim_serializer_8 \
      and not test_sim_serializer_8_phase90 \
      and not test_sim_serializer_8_phase90_check0 \
      and not test_sim_serializer_8_phase90_gen0"
  '';

  # For more information on why this hack is needed, see the
  # `pythonCheckInputsMagic.nix` file.
  ${import ./pythonCheckInputsMagic.nix lib buildPythonPackage} = [
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

    # Some cross compilations seem to have issues when linking
    # picolibc. This one seems to work, but may or may not be built by
    # Hydra.
    pkgsCross.riscv64-embedded.buildPackages.gcc
  ];

  doCheck = true;
}
