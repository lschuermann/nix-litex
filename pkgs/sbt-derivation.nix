{ pkgs, sbt, jre8 }:
let
  mkSbtDerivation = import (fetchTarball {
    name = "sbt-derivation-2023-10-27";
    url = "https://github.com/zaninime/sbt-derivation/archive/6762cf2c31de50efd9ff905cbcc87239995a4ef9.tar.gz";
    sha256 = "sha256:0g9dzw734k4qhvc4h88zjbrxdiz6g8kgq7qgbac8jgj8cvns6xry";
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
