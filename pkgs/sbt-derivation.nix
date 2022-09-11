{ pkgs, sbt, jre8 }:
let
  mkSbtDerivation = import (fetchTarball {
    name = "sbt-derivation-2022-08-30";
    url = "https://github.com/zaninime/sbt-derivation/archive/fe0044d2cd351f4d6257956cde3a2ef633d33616.tar.gz";
    sha256 = "sha256:04pi1a8g87pw4jjyzkj0aircpk8l2nxwy4lykwx8hg5m3gr4mr87";
  });

  overrides = {
    # the vexriscv cpu derivations use an old version of sbt which is broken on
    # javas past 8:
    # https://stackoverflow.com/questions/60308229/scala-packages-cannot-be-represented-as-uri
    sbt = sbt.override {
      jre = jre8;
    };
  };
in
# provide default package set and overrides for mkSbtDerivation function
args: mkSbtDerivation ({ inherit pkgs; } // args // { overrides = overrides // (args.overrides or { }); })
