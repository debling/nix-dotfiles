# Edited from: https://github.com/lilyinstarlight/nixos-cosmic/blob/fef2d0c78c4e4d6c600a88795af193131ff51bdc/pkgs/cosmic-ext-applet-clipboard-manager/package.nix
{
  lib,
  fetchFromGitHub,
  libcosmicAppHook,
  rustPlatform,
  stdenv,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "cosmic-ext-applet-clipboard-manager";
  version = "0.1.0-unstable-2025-03-05";

  src = fetchFromGitHub {
    owner = "cosmic-utils";
    repo = "clipboard-manager";
    rev = "cb8f33f5c390a685bd7fdff8c86a845c5936fe6e";
    hash = "sha256-qV28cWj4Sh/3jcanf7VoU2QdC37qRvzNSU1vc/8Pf3k=";
  };

  cargoHash = "sha256-+yqFV8HdPjkVny+6FKkZFEQAq1rwe7JXmoTJ7zge8bg=";

  nativeBuildInputs = [ libcosmicAppHook ];

  postInstall = ''
    binDir="$out/bin"
    mkdir -p "$binDir"
    cp target/${stdenv.hostPlatform.rust.rustcTarget}/release/cosmic-ext-applet-clipboard-manager "$binDir/"
    install -Dm0644 res/desktop_entry.desktop "$out/share/applications/io.github.cosmic_utils.cosmic-ext-applet-clipboard-manager.desktop"
    install -Dm0644 res/metainfo.xml "$out/share/metainfo/io.github.cosmic_utils.cosmic-ext-applet-clipboard-manager.metainfo.xml"
    install -Dm0644 res/app_icon.svg "$out/share/icons/hicolor/scalable/apps/io.github.cosmic_utils.cosmic-ext-applet-clipboard-manager-symbolic.svg"
    install -Dm0644 res/config_schema.json "$out/share/configurator/io.github.cosmic_utils.cosmic-ext-applet-clipboard-manager.json"
  '';

  preCheck = ''
    export XDG_RUNTIME_DIR="$TMP"
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    homepage = "https://github.com/cosmic-utils/clipboard-manager";
    description = "Clipboard manager for the COSMIC Desktop Environment";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-ext-applet-clipboard-manager";
  };
}
