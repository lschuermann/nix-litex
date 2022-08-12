pkgMeta:
{ callPackage
, buildPythonPackage
, generated ? callPackage (import ./generated.nix pkgMeta) { }
}:

buildPythonPackage rec {
  pname = "pythondata-cpu-vexriscv_smp";
  version = pkgMeta.git_revision;

  src = generated;

  doCheck = false;

  passthru = { inherit generated; };
}
