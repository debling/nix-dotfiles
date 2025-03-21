{ pkgs, ... }:

with pkgs;

let
  withFx = jdk: jdk.override { enableJavaFX = true; };
  latest_jdk = withFx jdk23;
  javadoc = callPackage ./javadoc.nix { jdk = latest_jdk; };
in
{
  home = {
    packages = [ latest_jdk javadoc mvnd scenebuilder ];
    file = {
      # Stable SDK symlinks
      "SDKs/Java/23".source = (withFx jdk23).home;
      "SDKs/Java/21".source = (withFx jdk21).home;
      "SDKs/Java/17".source = (withFx jdk17).home;
      "SDKs/Java/11".source = (withFx jdk11).home;
      "SDKs/Java/8".source = (withFx jdk8).home;
      "SDKs/graalvm".source = graalvmPackages.graalvm-ce.home;
    };

    sessionVariables = {
      GRAALVM_HOME = graalvmPackages.graalvm-ce.home;
      JAVA_HOME = latest_jdk.home;
    };
  };
}
