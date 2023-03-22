# In the current NixOS unstable branch (to be nixos-23.05), `buildPythonPackage`
# has been adjusted to rename `checkInputs` to `nativeCheckInputs`, breaking
# existing checkInputs specifications because of `strictDeps = 1;`. For more
# information, check out the corresponding PR at [1]. This implements the
# proposed workaround[2] for supporting both the current nixos-unstable and the
# last release branch (NixOS 22.11).
#
# It furthermore attempts to identify revisions of the 23.05pre-git
# unstable which did not include this patch.
#
# It returns either "checkInputs" or "nativeCheckInputs", whichever seems
# appropriate.
#
# [1]: https://github.com/NixOS/nixpkgs/pull/206742
# [2]: https://github.com/NixOS/nixpkgs/pull/206742#issuecomment-1417674430

lib: buildPythonPackage:

let
  # We check for whether a `buildPythonPackage` derivation with
  # `nativeCheckInputs` explicit set propagates this attribute. Commits which
  # use `nativeCheckInputs` to actually specify checkPhase dependencies will
  # stop this attribute from being propagated.
  #
  # This does rely on the inner workings of `buildPythonPackage` and hence
  # should only be used on revisions where this is known to work.
  hasNativeCheckInputs = !(
    builtins.hasAttr "nativeCheckInputs" (
      buildPythonPackage {
        name = "test";
        nativeCheckInputs = [ ];
      })
  );

in

# We limit the nixpkgs revisions of where the `hasNativeCheckInputs` test is
  # used to versions older than 23.05 (including 23.05-pre). This is to avoid
  # `buildPythonPackage` changing and thus breaking this test in the future.
if lib.versionAtLeast lib.version "23.05" || hasNativeCheckInputs then
  "nativeCheckInputs"
else
  "checkInputs"

