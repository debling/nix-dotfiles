{ buildGoModule, fetchFromGitHub, lib }:

let
  rev = "da4c8d5c1ca9b7d72dcdaa61f9d93bc2e12b7a5e";
  owner = "tsoding";
  repo = "snitch";
in
buildGoModule {
  pname = repo;
  version = builtins.substring 0 7 rev;

  src = fetchFromGitHub {
    owner = owner;
    repo = repo;
    rev = rev;
    sha256 = "M3FZs4GL0AXXUFH+VHFTI12aZx12RfgOWJltU6sOMfw=";
  };

  patches = [
    ./patches/0001-Adding-support-for-gitlab-groups-and-subgroups.patch
  ];
  vendorHash = "sha256-fGmoD4aEWNKs2OxlXA3xvUbC4ZxwtcoK9lUrWN5Gs5k=";
  proxyVendor = true;

  meta = with lib; {
    description = "Language agnostic tool that collects TODOs in the source code and reports them as Issues";
    homepage = "https://github.com/${owner}/${name}";
    license = licenses.mit;
  };
}
