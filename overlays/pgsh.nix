{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  fetchYarnDeps,
}:

let
  repo = "pgsh";
  owner = "sastraxi";
  version = "v0.12.0";
in
buildNpmPackage {
  inherit version;
  pname = repo;

  src = fetchFromGitHub {
    inherit owner repo;
    rev = version;
    hash = "sha256-PfVwUY+vr/iyrTsc631fegNO9kw1CuhxrBT0hnmIkmU=";
  };

  # npmDepsHash = "sha256-tuEfyePwlOy2/mOPdXbqJskO6IowvAP4DWg8xSZwbJw=";
  offlineCache = fetchYarnDeps {
    yarnLock = src + "/yarn.lock";
    hash = "sha256-tuEfyePwlOy2/mOPdXbqJskO6IowvAP4DWg8xSZwbJw=";
  };

  # The prepack script runs the build script, which we'd rather do in the build phase.
  # npmPackFlags = [ "--ignore-scripts" ];
  #
  # NODE_OPTIONS = "--openssl-legacy-provider";

  meta = with lib; {
    description = " Branch your PostgreSQL Database like Git ";
    homepage = "https://github.com/sastraxi/pgsh";
    license = licenses.mit;
  };
}
