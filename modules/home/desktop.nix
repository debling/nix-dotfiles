{
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./emacs.nix
  ];

  home = {
    packages = with pkgs; [
      libnotify
      zathura
      kicad
      jellyfin-media-player
      hledger-web
    ];
  };

  programs = {
    vscode = {
      enable = true;
      mutableExtensionsDir = true;
      package = pkgs.vscodium;
      profiles.default = {
        enableUpdateCheck = false;
        userSettings = {
          "files.autoSave" = "afterDelay";
          "vim.enableNeovim" = true;
          "editor.fontFamily" = "'JetBrains Mono', Menlo, Monaco, 'Courier New', monospace";
          "editor.fontSize" = 14;
          "editor.fontLigatures" = true;
          "workbench.colorTheme" = "Solarized Light";
          "vim.easymotion" = true;
          "vim.incsearch" = true;
          "vim.useSystemClipboard" = true;
          "vim.useCtrlKeys" = true;
          "vim.hlsearch" = true;
          "vim.leader" = "<space>";
          "extensions.experimental.affinity" = {
            "vscodevim.vim" = 1;
          };
          "zig.path" = "zig";
          "zig.zls.path" = "zig";
        };
      };
    };

    rbw = lib.mkIf pkgs.stdenv.isLinux {
      settings.pinentry = lib.mkForce pkgs.pinentry-gnome3;
    };
  };

  services.kdeconnect.enable = true;

  home.file.".gnupg/gpg-agent.conf".text =
    let
      pinentryPkgs = if pkgs.stdenv.isDarwin then pkgs.pinentry_mac else pkgs.pinentry-gnome3;
    in
    lib.mkIf pkgs.stdenv.isLinux (lib.mkForce ''
      allow-preset-passphrase
      max-cache-ttl 60480000
      default-cache-ttl 60480000
      pinentry-program ${lib.getExe pinentryPkgs}
    '');
}