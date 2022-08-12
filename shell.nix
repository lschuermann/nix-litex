# A nix-shell expression with the collection of build inputs for the
# various board expressions. Can be helpful when developing and
# debugging LiteX.

{ pkgs ? (import <nixpkgs> { }), enableVivado ? false, skipPkgChecks ? true }:

with pkgs;

let
  # import the litex package set and overlay it onto nixpkgs so we can
  # modify the packages inside it
  litexImport = (import ./pkgs { inherit pkgs; skipChecks = skipPkgChecks; });
  litexPkgs = (import pkgs.path {
    overlays = [
      litexImport.overlay

      (self: super: {
        maintenance = litexImport.maintenance;

        # override the CPU to add a patch, will be automatically rebuilt
        python3 = super.python3.override {
          packageOverrides = p-self: p-super: {
            pythondata-cpu-vexriscv = (p-super.pythondata-cpu-vexriscv.override ({
              generated = p-super.pythondata-cpu-vexriscv.generated.overrideAttrs (prev: {
                patches = (prev.patches or [ ]) ++ [
                  ./pkgs/pythondata-cpu-vexriscv/0001-Add-TockSecureIMC-cpu-variant.patch
                ];
              });
            }));
          };
        };
      })
    ];
  });

in
pkgs.mkShell {
  name = "litex-shell";
  buildInputs = with litexPkgs; with litexPkgs.python3Packages; [
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
    pythondata-cpu-vexriscv_smp
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
