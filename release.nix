# release.nix file for evaluation with Hydra

{ nixpkgsSrc }:

(import ./default.nix {
  pkgs = import nixpkgsSrc { };
  skipChecks = false;
}).packages
