{ lib
, stdenv
, fetchFromGitHub
, pkg-config
, wayland
, wayland-protocols
, pixman
, fcft
, wayland-scanner
}:

stdenv.mkDerivation {
  pname = "dwlb";
  version = "git";

  src = fetchFromGitHub {
    owner = "kolunmi";
    repo = "dwlb";
    rev = "0daa1c1fdd82c4d790e477bf171e23ca2fdfa0cb";
    hash = "sha256-Bu20IqRwBP1WRBgbcEQU4Q2BZ2FBnVaySOTsCn0iSSE=";
  };


  nativeBuildInputs = [ pkg-config wayland-scanner ];
  buildInputs = [ wayland wayland-protocols fcft pixman ];

  makeFlags = [ "PREFIX=$(out)" ];

  meta =  {
    homepage = "https://github.com/MadcowOG/dwl-bar";
    description = "Feature-Complete Bar for DWL";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux;
    mainProgram = "dwlb";
  };
}
