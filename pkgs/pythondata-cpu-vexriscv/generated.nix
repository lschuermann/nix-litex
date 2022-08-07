pkgMeta:
{ stdenv }:

stdenv.mkDerivation rec {
  pname = "pythondata-cpu-vexriscv-generated";
  version = pkgMeta.git_revision;

  src = builtins.fetchGit {
    url = "https://github.com/${pkgMeta.github_user}/${pkgMeta.github_repo}";
    rev = pkgMeta.git_revision;
    submodules = true;
  };

  installPhase = ''
    # the build product is the python package with the updated verilog
    # modules. copy the updated python package as our output so we can then  
    # install it as a normal python package.
    mkdir -p $out
    cp -r * $out
  '';
}
