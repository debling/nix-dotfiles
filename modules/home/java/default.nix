{ pkgs, ...}:

with pkgs;

let 
  latest_jdk = jdk23;
  javadoc = callPackage ./javadoc.nix { jdk = latest_jdk; };
in {
  home = {
    packages = [ latest_jdk javadoc mvnd ];
    file = { 
      # Stable SDK symlinks
      "SDKs/Java/23".source = jdk23.home;
      "SDKs/Java/21".source = jdk21.home;
      "SDKs/Java/17".source = jdk17.home;
      "SDKs/Java/11".source = jdk11.home;
      "SDKs/Java/8".source  = jdk8.home;
      "SDKs/graalvm".source = graalvmPackages.graalvm-ce.home;
    };

    sessionVariables = {
      GRAALVM_HOME = graalvmPackages.graalvm-ce.home;
      JAVA_HOME = latest_jdk.home;
    };
  };
}
