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
  version = "0.1.0-unstable-2026-10-25";

  src = fetchFromGitHub {
    owner = "cosmic-utils";
    repo = "clipboard-manager";
    rev = "27a246fab0c3051a89f67e137dddada1869145ca";
    hash = "sha256-SsP4DxaJtzfvQkGWQ+fZcIgUngyP94LRh+ymffowNHw=";
  };

  cargoHash = "sha256-ABo4fAtFCaIyNukOUZqHpBhR0fANkb/h7lz755LyRpA=";

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
