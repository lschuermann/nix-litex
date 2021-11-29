pkgMeta:
{ buildPythonPackage }:

buildPythonPackage rec {
  pname = "pythondata-cpu-serv";
  version = pkgMeta.git_revision;

  src = builtins.fetchGit {
    url = "https://github.com/${pkgMeta.github_user}/${pkgMeta.github_repo}";
    rev = pkgMeta.git_revision;
  };

  doCheck = false;
}
