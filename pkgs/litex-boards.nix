pkgMeta:
{ lib
, buildPythonPackage
, fetchFromGitHub
, python
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
}:

buildPythonPackage rec {
  pname = "litex-boards";
  version = pkgMeta.git_revision;

  src = fetchFromGitHub {
    owner = pkgMeta.github_user;
    repo = pkgMeta.github_repo;
    rev = pkgMeta.git_revision;
    sha256 = pkgMeta.github_archive_nix_hash;
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
  ];

  doCheck = true;
}
