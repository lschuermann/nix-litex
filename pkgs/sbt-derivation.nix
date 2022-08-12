{ pkgs, sbt, jre8 }:
let
  sbt-derivation = fetchTarball {
    name = "sbt-derivation-2021-04-03";
    url = "https://github.com/zaninime/sbt-derivation/archive/920b6f187937493371e2b1687261017e6e014cf1.tar.gz";
    sha256 = "sha256:0apg8mk7bzq418c1jyq5s5c3sp6bh4smirwxi29dhbnyp8q9ddv7";
  };
in
pkgs.callPackage "${sbt-derivation}/pkgs/sbt-derivation" {
  # the vexriscv cpu derivations use an old version of sbt which is broken on
  # javas past 8:
  # https://stackoverflow.com/questions/60308229/scala-packages-cannot-be-represented-as-uri
  sbt = sbt.override {
    jre = jre8;
  };
}
