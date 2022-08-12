pkgMeta:
{ sbt-mkDerivation, python3, litex-unchecked, migen }:
let
  # python environment with the litex used to generate the default CPU variants
  pythonEnv = python3.withPackages (_: [ litex-unchecked migen ]);
in
sbt-mkDerivation rec {
  pname = "pythondata-cpu-vexriscv_smp-generated";
  version = pkgMeta.git_revision;

  src = builtins.fetchGit {
    url = "https://github.com/${pkgMeta.github_user}/${pkgMeta.github_repo}";
    rev = pkgMeta.git_revision;
    submodules = true;
  };

  # sbt needs to compile at least one file in order to download all the
  # dependencies, but we don't want it to compile all of the project in order
  # to save time and resource hassles. so delete the source and compile a fake
  # file to get sbt to do its job properly.
  depsWarmupCommand = ''
    # find directories which contain source code and replace them with
    # one empty file (except for the idslplugin which needs to still exist
    # so the fake compilation will work)
    find . -wholename "*/src/main" -print0 | grep -z -v idslplugin | \
      xargs -0 -I{} bash -c 'rm -rf {}/../../src && mkdir -p {}/scala && touch {}/scala/dummy.scala'

    # ask sbt to compile the main project
    pushd pythondata_cpu_vexriscv_smp/verilog/ext/VexRiscv
    sbt compile
    popd

    # save sbt's dependency directory where the sbt-mkDerivation infra
    # expects it
    mv pythondata_cpu_vexriscv_smp/verilog/ext/VexRiscv/.nix .
  '';

  # if any sbt files or dependencies change, change this hash to cause nix to
  # regenerate them, then replace this with the hash it gives you and rebuild.
  # not doing this will break reproducibility and may cause sbt to report
  # errors that it can't download stuff during the build.
  depsSha256 = "sha256-XxcGG9sy2FJUL5ppBrDCtbkkGdlZ/CAatdAGl2gZ0ks=";

  buildPhase = ''
    runHook preBuild

    # move dependencies to where sbt expects them
    mv .nix pythondata_cpu_vexriscv_smp/verilog/ext/VexRiscv

    # delete old CPU variant sources
    rm pythondata_cpu_vexriscv_smp/verilog/VexRiscv*.v

    # rebuild all CPU variants
    ${pythonEnv}/bin/python generate.py

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    # remove SBT dependencies and build artifacts
    rm -rf pythondata_cpu_vexriscv_smp/verilog/ext/VexRiscv/.nix

    find . -wholename "*/src/main" -print0 | \
      xargs -0 -I{} bash -c 'rm -rf {}/../../{target,project/project,project/target}'

    # VexRiscv writes the current timestamp into the generated
    # output, which breaks reproducibility. Remove it.
    find . -iname '*.v' -execdir sed '/^\/\/ Date      :/d' -i {} \;

    # the build product is the python package with the updated verilog
    # modules. copy the updated python package as our output so we can then
    # install it as a normal python package.
    mkdir -p $out
    cp -r * $out

    runHook postInstall
  '';
}
