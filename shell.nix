# A nix-shell expression with the collection of build inputs for the
# various board expressions. Can be helpful when developing and
# debugging LiteX.

{ pkgs ? (import <nixpkgs> { }), enableVivado ? false, skipPkgChecks ? true }:

with pkgs;

let
  litexPkgs = import ./pkgs { inherit pkgs; skipChecks = skipPkgChecks; };

in
pkgs.mkShell {
  name = "litex-shell";
  buildInputs = with litexPkgs; [
    python3Packages.migen
    openocd

    litex
    litex-boards
    litedram
    liteeth
    liteiclink
    litescope
    litespi
    litepcie
    litehyperbus
    pythondata-cpu-vexriscv
    pkgsCross.riscv64.buildPackages.gcc
    gnumake
    python3Packages.pyvcd

    # For simulation
    pythondata-misc-tapcfg
    libevent
    json_c
    zlib
    verilator

    # For ECP5 bitstream builds
    yosys
    nextpnr
    icestorm

    # For executing the maintenance scripts of this repository
    maintenance

    # For LiteX development
    python3Packages.pytest
    python3Packages.pytest-xdist
    python3Packages.pytest-subtests
  ] ++ (if enableVivado then [ (pkgs.callPackage ./pkgs/vivado { }) ] else [ ]);
}
