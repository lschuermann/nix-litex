pkgMeta:
{ lib
, buildPythonPackage
, litex
, liteiclink
, migen
, litex-boards
, litescope
, litedram
, litespi
, pyyaml
}:

buildPythonPackage rec {
  pname = "liteeth";
  version = pkgMeta.git_revision;

  src = builtins.fetchGit {
    url = "https://github.com/${pkgMeta.github_user}/${pkgMeta.github_repo}";
    rev = pkgMeta.git_revision;
  };

  buildInputs = [
    litex
  ];

  # For more information on why this hack is needed, see the
  # `pythonCheckInputsMagic.nix` file.
  ${import ./pythonCheckInputsMagic.nix lib buildPythonPackage} = [
    # Some of these are really only required because litex-boards
    # needs them for importing all targets in its __init__.py.
    liteiclink
    migen
    litex-boards
    litescope
    litedram
    litespi
    pyyaml
  ];

  doCheck = true;
}
