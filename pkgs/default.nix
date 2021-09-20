let
  # Use builtins.fromTOML if available, otherwise use remarshal to
  # generate JSON which can be read. Code taken from
  # nixpkgs/pkgs/development/tools/poetry2nix/poetry2nix/lib.nix.
  fromTOML = pkgs: builtins.fromTOML or (
    toml: builtins.fromJSON (
      builtins.readFile (
        pkgs.runCommand "from-toml"
          {
            inherit toml;
            allowSubstitutes = false;
            preferLocalBuild = true;
          }
          ''
            ${pkgs.remarshal}/bin/remarshal \
              -if toml \
              -i <(echo "$toml") \
              -of json \
              -o $out
          ''
      )
    )
  );
in

# pkgMetas: Metadata for the packages such that you can control which revisions
  # are used. If not specified, the versions will be taken from `litex_packages.toml`.
{ pkgs, skipChecks ? false, pkgMetas ? fromTOML pkgs (builtins.readFile ./litex_packages.toml) }:

let
  lib = pkgs.lib;

  unchecked = drv: drv.overrideAttrs (_: {
    doCheck = false;
  });

  testedPkgs = [
    "litex"
    "litedram"
    "litex-boards"
    "liteeth"
    "litedram"
    "litehyperbus"
    "liteiclink"
    "litepcie"
    "litescope"
    "litesdcard"
    "litespi"
  ];

  # Make an unchecked package
  makeUnchecked = self: name:
    let
      f = import (./. + "/${name}.nix") pkgMetas.${name};
      argNames = lib.intersectLists testedPkgs (builtins.attrNames (lib.functionArgs f));
      args = builtins.foldl' (acc: name: acc // { ${name} = self.${"${name}-unchecked"}; }) { } argNames;
      maker = attrs: self.buildPythonPackage (attrs // {
        pname = "${attrs.pname}-pkg";
        doCheck = false;
        passthru._base_name = attrs.pname;
      });
    in
    self.callPackage f (args // { buildPythonPackage = maker; });

  # Make a test for the package
  makeTest = self: name:
    let
      f = import (./. + "/${name}.nix") pkgMetas.${name};
      argNames = lib.intersectLists testedPkgs (builtins.attrNames (lib.functionArgs f));
      args = builtins.foldl' (acc: name: acc // { ${name} = self.${"${name}-unchecked"}; }) { } argNames;
      maker = attrs: self.buildPythonPackage (attrs // {
        pname = "${attrs.pname}-test";
        installPhase = "mkdir $out";
      });
    in
    self.callPackage f (args // { buildPythonPackage = maker; });

  # Forward the unchecked package but depend on tests
  makeFinal = self: name:
    let
      f = import (./. + "/${name}.nix") pkgMetas.${name};
      argNames = lib.intersectLists testedPkgs (builtins.attrNames (lib.functionArgs f));
      pkg = self.${"${name}-unchecked"};
      passthru = [ "meta" ];
      args = {
        pname = pkg._base_name;
        inherit (pkg) version;

        src = pkgs.linkFarm "empty" [ ];

        nativeBuildInputs =
          if skipChecks
          then [ ]
          else builtins.foldl' (acc: name: acc ++ [ self.${"${name}-test"} ]) [ self.${"${name}-test"} ] argNames;

        unpackPhase = "true";
        patchPhase = "true";
        configurePhase = "true";
        buildPhase = "true";

        installPhase = ''
          ln -s ${pkg} $out
          runHook postInstall
        '';

        fixupPhase = "true";
        setupToolsCheckPhase = "true";

        doCheck = false;
      };
    in
    self.buildPythonPackage (
      builtins.foldl'
        (acc: elem: acc // (if pkg ? ${elem} then { ${elem} = pkg.${elem}; } else { }))
        args
        passthru
    );

  # Overlay for python packages.
  pythonOverlay = self: super:
    builtins.foldl'
      (acc: name: acc // {
        "${name}-unchecked" = makeUnchecked self name;
        "${name}-test" = makeTest self name;
        "${name}" = makeFinal self name;
      })
      { }
      testedPkgs
    // {
      pythondata-cpu-vexriscv =
        self.callPackage (import ./pythondata-cpu-vexriscv) { };
      pythondata-misc-tapcfg =
        self.callPackage (import ./pythondata-misc-tapcfg.nix pkgMetas.pythondata-misc-tapcfg) { };
      pythondata-software-compiler_rt =
        self.callPackage (import ./pythondata-software-compiler_rt.nix pkgMetas.pythondata-software-compiler_rt) { };
      pythondata-cpu-serv =
        self.callPackage (import ./pythondata-cpu-serv.nix pkgMetas.pythondata-cpu-serv) { };
    };

  applyOverlay = python: python.override {
    packageOverrides = pythonOverlay;
  };

  overlay = self: super: {
    # Why...
    python3 = applyOverlay super.python3;
    python37 = applyOverlay super.python37;
    python38 = applyOverlay super.python38;
    python39 = applyOverlay super.python39;
    python310 = applyOverlay super.python310;
  };

  extended = pkgs.extend overlay;

  pkgSet =
    builtins.foldl'
      (acc: elem: acc // {
        ${elem} = extended.python3Packages.${elem};
      })
      { }
      (
        builtins.concatLists (builtins.map (x: [ "${x}-unchecked" "${x}-test" x ]) testedPkgs)
        ++ [
          "pythondata-cpu-vexriscv"
          "pythondata-misc-tapcfg"
          "pythondata-software-compiler_rt"
          "pythondata-cpu-serv"
        ]
      );
in
pkgSet // { inherit overlay pythonOverlay; packages = pkgSet; nixpkgsExtended = extended; }
