pkgMeta:
{ lib
, buildPythonPackage
, python
, pytest
, migen
, litex
, litedram
, liteeth
, liteiclink
, litepcie
, pythondata-cpu-vexriscv
, litespi
, litehyperbus
, valentyusb-hw_cdc_eptri
, litevideo
, litescope
, litesdcard
, pythondata-misc-usb_ohci
}:

buildPythonPackage rec {
  pname = "litex-boards";
  version = pkgMeta.git_revision;

  src = builtins.fetchGit {
    url = "https://github.com/${pkgMeta.github_user}/${pkgMeta.github_repo}";
    rev = pkgMeta.git_revision;
  };

  # Won't pick up the shebangs in litex_boards/targets/ automatically,
  # so need to do that manually here.
  patchPhase = ''
    patchShebangs litex_boards/targets/*
  '';

  # All of these are required for the __init__.py in this repository
  # to work, specifically the line
  #
  # t = importlib.import_module(f"litex_boards.targets.{target}")`
  #
  # This will try to import every target and thus fail if a dependency
  # cannot be resolved.
  propagatedBuildInputs = [
    migen
    litex
    litedram
    liteeth
    liteiclink
    litepcie
    litehyperbus
    pythondata-cpu-vexriscv
    litespi
    valentyusb-hw_cdc_eptri
    litevideo
    litescope
    litesdcard
    pythondata-misc-usb_ohci
  ];

  doCheck = true;

  # For more information on why this hack is needed, see the
  # `pythonCheckInputsMagic.nix` file.
  ${import ./pythonCheckInputsMagic.nix lib buildPythonPackage} = [
    pytest
  ];
  checkPhase = ''
    ln -s ${builtins.fetchurl {
      url = "https://github.com/enjoy-digital/litex/files/6076336/ter-u16b.txt";
      sha256 = "02jg4yah9nr5cln6apx72fp01c4ylvskvi2gfv65wk7rsvn1z1lj";
    }} ./ter-u16b.bdf
    ln -s ${builtins.fetchurl {
      url = "https://github.com/litex-hub/litex-boards/files/8831568/hyperbus.py.txt";
      sha256 = "199aqd4i8jaqdhv8frgsmmsgavz63g6z5mv1y5w19q5mjzwwssz4";
    }} ./hyperbus.py
    pytest -v test/
  '';
}
