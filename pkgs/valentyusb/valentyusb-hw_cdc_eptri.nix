pkgMeta:
{ lib, buildPythonPackage, litex, cocotb, sigrok-cli, verilog }:

buildPythonPackage rec {
  pname = "valentyusb-hw_cdc_eptri";
  version = pkgMeta.git_revision;

  src = builtins.fetchGit {
    url = "https://github.com/${pkgMeta.github_user}/${pkgMeta.github_repo}";
    ref = "refs/heads/${pkgMeta.git_branch}";
    rev = pkgMeta.git_revision;
  };

  buildInputs = [
    litex
  ];

  # For more information on why this hack is needed, see the
  # `pythonCheckInputsMagic.nix` file.
  ${import ../pythonCheckInputsMagic.nix lib buildPythonPackage} = [
    cocotb
    sigrok-cli
    verilog
  ];

  # Checks are currently broken. It looks like upstream LiteX has
  # advanced too far and valentyusb (or the respective fork with
  # hw_cdc_eptri branch) hasn't cought up yet. This could potentially
  # mean that building boards which depend on valentyusb could fail.
  doCheck = false;
}
