{
  pkgs,
  jdk ? pkgs.jdk,
}:

with pkgs;

stdenv.mkDerivation {
  name = "${jdk.name}-javadoc";

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [
    jdk
    unzip
  ];
  phases = [
    "buildPhase"
    "installPhase"
  ];

  buildPhase = ''
    unzip -q "${jdk}/lib/src.zip" -d src/
    pushd src 
    java_modules=$(for module in *; do echo --module "$module"; done)
    javadoc -d ../javadoc --module-source-path . $java_modules || true
    popd
  '';

  installPhase = ''
    mkdir -p $out/share
    mv javadoc $out/share/

    mkdir -p $out/bin
    echo -e "#!/bin/sh\n xdg-open $out/share/javadoc/index.html" > $out/bin/open-javadoc
    chmod +x $out/bin/open-javadoc
    wrapProgram $out/bin/open-javadoc \
      --prefix PATH : ${lib.makeBinPath [ xdg-utils ]}
  '';
}
