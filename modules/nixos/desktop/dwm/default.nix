{
  lib,
  pkgs,
  mainUser,
  colorscheme,
  ...
}:

let
  # Patches for dwm 6.8:
  # - barpadding + systray: the official dwm-barpadding-6.6.diff applies
  #   cleanly to 6.8, but the systray patch rewrites the same lines
  #   (resizebarwin, drawbar, togglebar, updatebars), so the two official
  #   patches cannot be stacked as-is. These vendored
  #   dwm-barpadding-systray-6.8-nixpkgs.*.diff files merge both, following
  #   the pad-aware systray variant from
  #   https://dwm.suckless.org/patches/systray/dwm-systray-6.6.diff
  #   (20251118), with the three hunks that 6.8 changed upstream
  #   (getatomprop `format` -> `di`, buttonpress, setfocus) re-applied
  #   against the current sources.
  # - fullgaps: inner + outer gaps with a per-monitor `gappx` and a
  #   `setgaps` keybind callback. (The upstream `gaps` patch only exists for
  #   dwm 6.0; fullgaps is its maintained equivalent.)
  dwm-barpadding-systray-c-patch = ./dwm-barpadding-systray-6.8-nixpkgs.c.diff;
  dwm-barpadding-systray-h-patch = ./dwm-barpadding-systray-6.8-nixpkgs.h.diff;
  dwm-fullgaps-patch = pkgs.fetchurl {
    url = "https://dwm.suckless.org/patches/fullgaps/dwm-fullgaps-6.4.diff";
    hash = "sha256-DvLNPOwDfaZj9o2n+t+xh6fj8X7EFW38ZWV5jzRhXxU=";
  };

  # config.def.h with the nix-colors palette (gruvbox-dark-hard) substituted
  # into the @baseXX@ placeholders
  dwm-conf = pkgs.runCommand "dwm-config.def.h" { } ''
    cp ${./config.def.h} "$out"
    substituteInPlace "$out" \
      --replace-fail @base00@ "${colorscheme.palette.base00}" \
      --replace-fail @base01@ "${colorscheme.palette.base01}" \
      --replace-fail @base02@ "${colorscheme.palette.base02}" \
      --replace-fail @base03@ "${colorscheme.palette.base03}" \
      --replace-fail @base04@ "${colorscheme.palette.base04}" \
      --replace-fail @base06@ "${colorscheme.palette.base06}" \
      --replace-fail @base0B@ "${colorscheme.palette.base0B}"
  '';

  dwm = pkgs.dwm.override {
    conf = dwm-conf;
    patches = [
      dwm-barpadding-systray-h-patch
      dwm-barpadding-systray-c-patch
      dwm-fullgaps-patch
      # sets the _DWM_TILED X property (CARDINAL 1) on tiled windows and
      # removes it on floating ones, so picom's shadow-exclude can target
      # shadows at floating windows only
      ./dwm-floating-hint-6.8.diff
    ];
  };

  slstatus = pkgs.slstatus.override {
    conf = ./slstatus-config.h;
  };

  # st-config.def.h with the nix-colors palette (gruvbox-dark-hard)
  # substituted into the @baseXX@ placeholders. st's `conf` override expects
  # the config text (writeText), so the substitution happens in Nix.
  st-conf =
    let
      palette = colorscheme.palette;
      placeholders = [
        "@base00@"
        "@base01@"
        "@base03@"
        "@base04@"
        "@base06@"
        "@base08@"
        "@base09@"
        "@base0A@"
        "@base0B@"
        "@base0C@"
        "@base0D@"
        "@base0E@"
      ];
    in
    lib.replaceStrings placeholders (map (
      n: palette.${lib.removePrefix "@" (lib.removeSuffix "@" n)}
    ) placeholders) (builtins.readFile ./st-config.def.h);

  # st patch stack (one official patch per file; see each file's header for
  # provenance and any local rebases):
  # - config-shell (vendored, not upstream): makes the config.def.h `shell`
  #   authoritative so st execs it instead of the session's $SHELL / passwd
  #   shell (needed because the login shell is bash, but st should be fish)
  # - anysize: fill the full space allocated by the tiling WM
  # - fontmetrics: cell height + underline/strikethrough geometry from the
  #   font's OS/2 table
  # - boxdraw: render lines/blocks/braille for gapless alignment (enabled in
  #   st-config.def.h)
  # - newterm: Ctrl+Shift+Return spawns a new st in the current directory.
  #   Note: the old combined patch carried two extra hunks from the 0.8.5
  #   variant (OpenBSD-only pledge + a sigchld zombie-reaping tweak made
  #   redundant by SA_RESTART); the official 0.9 patch omits them.
  # - open_selected_text: Ctrl+Middle-click opens the selected text with
  #   xdg-open (zen-beta is the xdg default browser). Replaces the old
  #   externalpipe/urlopencmd screen-scan flow.
  st =
    (pkgs.st.override {
      conf = st-conf;
      patches = [
        ./st-config-shell-0.9.3.diff
        ./st-anysize-20220718-baa9357.diff
        ./st-fontmetrics-0.9.3.diff
        ./st-boxdraw-0.9.3-nixpkgs.diff
        ./st-newterm-0.9.diff
        ./st-open-selected-0.9.2-nixpkgs.diff
      ];
    }).overrideAttrs
      (old: {
        # nixpkgs st packaging bug (present in the locked rev and still in
        # master): postPatch concatenates the `cp <conf> config.def.h` fragment
        # with the `substituteInPlace config.mk ...` fragment without any
        # separator when `conf` is set, so the shell runs
        # `cp <conf> config.def.hsubstituteInPlace ...` and fails with
        # "cp: unrecognized option '--replace-fail'". Restore the missing
        # newline; becomes a harmless no-op once upstream fixes the recipe.
        postPatch =
          lib.replaceStrings [ "config.def.hsubstituteInPlace" ] [ "config.def.h\nsubstituteInPlace" ]
            old.postPatch;
      });

  # The xinit client: startx brings the X server up (via the NixOS-generated
  # xserverrc) and runs this with DISPLAY set
  dwm-run = pkgs.writeShellScriptBin "dwm-run" ''
    export XDG_SESSION_TYPE=x11
    export XDG_CURRENT_DESKTOP=dwm
    export XDG_SESSION_DESKTOP=dwm

    dbus-update-activation-environment --systemd DISPLAY XAUTHORITY XDG_SESSION_TYPE XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP >/dev/null || true
    systemctl --user import-environment DISPLAY XAUTHORITY XDG_SESSION_TYPE XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP >/dev/null || true

    # Start the graphical session target explicitly: user units (autorandr,
    # dunst, picom) are WantedBy it, but nothing else pulls it in a
    # startx-based session (dwm-session.target only bindsTo it).
    systemctl --user start graphical-session.target || true

    systemctl --user start dwm-session.target || true

    ${slstatus}/bin/slstatus &
    ${pkgs.networkmanagerapplet}/bin/nm-applet &

    exec ${dwm}/bin/dwm
  '';

  # greetd / tuigreet entry: no PATH exports needed (NixOS already provides
  # the correct user session PATH), no manual X handling - startx owns the
  # X server lifecycle via the NixOS-generated xserverrc. stderr goes to a
  # log file so launch failures (e.g. from the tuigreet session picker)
  # aren't lost to the tty.
  dwm-session = pkgs.writeShellScriptBin "dwm-session" ''
    if [ "''${XDG_SESSION_TYPE:-}" = "wayland" ]; then
      echo "dwm-session: refusing to nest an X session inside a Wayland session; run it from a virtual terminal" >&2
      exit 1
    fi

    exec ${lib.getExe' pkgs.xinit "startx"} ${dwm-run}/bin/dwm-run 2>> "$HOME/.dwm-session.log"
  '';

  dwm-desktop-session =
    (pkgs.writeTextDir "share/xsessions/dwm.desktop" ''
      [Desktop Entry]
      Name=dwm
      Exec=${dwm-session}/bin/dwm-session
      Type=Application
      DesktopNames=dwm
    '').overrideAttrs
      (_: {
        passthru.providedSessions = [ "dwm" ];
      });
in
{
  # Registers the "dwm" X11 session so it shows up in the cosmic-greeter
  # session picker alongside COSMIC. cosmic-greeter launches X11 sessions
  # via `startx /usr/bin/env XDG_SESSION_TYPE=x11 ... dwm-session`.
  services.displayManager.sessionPackages = [ dwm-desktop-session ];

  # Xorg stack for the startx-based session launch (and TTY fallback).
  # displayManager.startx generates /etc/X11/xinit/xserverrc with the NixOS
  # Xorg args and puts `xinit`/`startx` into the system PATH.
  services.xserver.enable = true;
  services.xserver.displayManager.startx.enable = true;

  environment.systemPackages = [
    dwm
    dwm-session
    dwm-run
    slstatus
    st
  ]
  ++ (with pkgs; [
    xauth # needed by startx
    rofi # application launcher (Super+p)
    wiremix # PipeWire TUI mixer (Super+v)
    networkmanagerapplet # systray network manager (nm-applet)
    brightnessctl # brightness keybinds
    playerctl # media keybinds
    feh # wallpaper setter
    xdg-utils # xdg-open for st's selopen (Ctrl+Middle-click)
  ]);

  # Rofi launcher themed like nix-community/stylix modules/rofi/hm.nix with
  # alternatePattern = false (uniform rows). All values are rasi literals:
  # plain strings would be emitted quoted, which rofi parses but silently
  # ignores at render time. HM's config.lib.formats.rasi.mkLiteral is not
  # reachable from a NixOS module, so rasiLiteral mirrors the serializer
  # shape it checks for (_type = "literal" -> value emitted unquoted).
  home-manager.users.${mainUser} = {
    # flameshot 14 uses the XDG portal by default, but no portal backend
    # implements Screenshot on X11 here (xdg-desktop-portal-gtk dropped it),
    # so the launcher hangs. useX11LegacyScreenshot restores native X11
    # capture.
    services.flameshot = {
      enable = true;
      settings.General.useX11LegacyScreenshot = true;
    };
    # Notification daemon (dwm has none of its own; flameshot and other
    # apps need org.freedesktop.Notifications). Started via the HM systemd
    # unit when graphical-session.target is activated by dwm-session.target.
    # Themed with the nix-colors palette (gruvbox-dark-hard).
    services.dunst = {
      enable = true;
      settings = with colorscheme.palette; {
        global = {
          font = "monospace 10";
          background = "#${base00}";
          foreground = "#${base04}";
          frame_color = "#${base0B}";
          notification_limit = 5;
          offset = "10x50";
          origin = "top-right";
        };
        urgency_low = {
          background = "#${base00}";
          foreground = "#${base04}";
          frame_color = "#${base03}";
        };
        urgency_normal = {
          background = "#${base00}";
          foreground = "#${base06}";
          frame_color = "#${base0B}";
        };
        urgency_critical = {
          background = "#${base00}";
          foreground = "#${base08}";
          frame_color = "#${base08}";
        };
      };
    };
    # HM's dunst module only sets PartOf/After; without this the daemon
    # never starts
    systemd.user.services.dunst.Install.WantedBy = [ "graphical-session.target" ];
    # dunst's icon_path defaults to hicolor only, which lacks most
    # device/app icons (audio-headset, flameshot, ...). Use the same icon
    # theme as the GTK session setup (gtk-qt.nix)
    services.dunst.iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme.override { color = "green"; };
      size = "32x32";
    };

    # Compositor, managed as a systemd user unit tied to
    # graphical-session.target (started by dwm-session.target). The
    # pijulius fork adds rounded corners and extra options.
    services.picom = {
      enable = true;
      package = pkgs.picom-pijulius;
      backend = "glx";
      vSync = true;
      fade = true;
      fadeDelta = 5;
      activeOpacity = 1.0;
      inactiveOpacity = 1.0;
      shadow = true;
      shadowOffsets = [
        (-7)
        (-7)
      ];
      shadowOpacity = 0.55;
      shadowExclude = [
        # the dwm bar + systray carry the "dwm" class
        "class_g = 'dwm'"
        "name = 'Notification'"
        "class_g ?= 'Notify-osd'"
        "window_type = 'dock'"
        # dwm sets _DWM_TILED = 1 on tiled windows (dwm-floating-hint-6.8.diff)
        "_DWM_TILED = 1"
      ];
      wintypes = {
        dock = {
          shadow = false;
        };
        tooltip = {
          shadow = false;
          fade = false;
        };
        popup_menu = {
          opacity = 0.9;
          shadow = false;
        };
        dropdown_menu = {
          opacity = 0.9;
          shadow = false;
        };
      };
      opacityRules = [
        "100:class_g = 'st'"
        "100:class_g = 'rofi'"
      ];
    };

    programs.rofi = {
      enable = true;
      terminal = "alacritty";
      font = "monospace 10";
      modes = [ "combi" ];
      extraConfig = {
        show-icons = true;
        combi-modi = "window,drun,run";
      };
      theme =
        let
          rasiLiteral = value: {
            _type = "literal";
            inherit value;
          };
          hexDigit =
            c:
            {
              "0" = 0;
              "1" = 1;
              "2" = 2;
              "3" = 3;
              "4" = 4;
              "5" = 5;
              "6" = 6;
              "7" = 7;
              "8" = 8;
              "9" = 9;
              "a" = 10;
              "b" = 11;
              "c" = 12;
              "d" = 13;
              "e" = 14;
              "f" = 15;
            }
            .${c};
          hexToRgb =
            hex:
            let
              c = lib.stringToCharacters hex;
            in
            "${toString (hexDigit (lib.elemAt c 0) * 16 + hexDigit (lib.elemAt c 1))}, ${
              toString (hexDigit (lib.elemAt c 2) * 16 + hexDigit (lib.elemAt c 3))
            }, ${toString (hexDigit (lib.elemAt c 4) * 16 + hexDigit (lib.elemAt c 5))}";
          mkRgba = opacity: color: rasiLiteral "rgba ( ${hexToRgb palette.${color}}, ${opacity} % )";
          mkRgb = mkRgba "100";
          palette = colorscheme.palette;
          # alternatePattern = false: alternates are identical to normal
          mkAlternate = base: alternate: base;
        in
        {
          "*" = rec {
            background = mkRgba "100" "base00";
            lightbg = mkRgba "100" "base01";
            red = mkRgba "100" "base08";
            blue = mkRgba "100" "base0D";
            lightfg = mkRgba "100" "base06";
            foreground = mkRgba "100" "base05";

            background-color = mkRgb "base00";
            separatorcolor = rasiLiteral "@foreground";
            border-color = rasiLiteral "@foreground";
            selected-normal-foreground = rasiLiteral "@lightbg";
            selected-normal-background = rasiLiteral "@lightfg";
            selected-active-foreground = rasiLiteral "@background";
            selected-active-background = rasiLiteral "@blue";
            selected-urgent-foreground = rasiLiteral "@background";
            selected-urgent-background = rasiLiteral "@red";
            normal-foreground = rasiLiteral "@foreground";
            normal-background = rasiLiteral "@background";
            active-foreground = rasiLiteral "@blue";
            active-background = rasiLiteral "@background";
            urgent-foreground = rasiLiteral "@red";
            urgent-background = rasiLiteral "@background";
            alternate-normal-foreground = mkAlternate normal-foreground (rasiLiteral "@foreground");
            alternate-normal-background = mkAlternate normal-background (rasiLiteral "@lightbg");
            alternate-active-foreground = mkAlternate active-foreground (rasiLiteral "@blue");
            alternate-active-background = mkAlternate active-background (rasiLiteral "@lightbg");
            alternate-urgent-foreground = mkAlternate urgent-foreground (rasiLiteral "@red");
            alternate-urgent-background = mkAlternate urgent-background (rasiLiteral "@lightbg");

            # Text colors
            base-text = mkRgb "base05";
            selected-normal-text = mkRgb "base01";
            selected-active-text = mkRgb "base00";
            selected-urgent-text = mkRgb "base00";
            normal-text = mkRgb "base05";
            active-text = mkRgb "base0D";
            urgent-text = mkRgb "base08";
            alternate-normal-text = mkAlternate normal-text (mkRgb "base05");
            alternate-active-text = mkAlternate active-text (mkRgb "base0D");
            alternate-urgent-text = mkAlternate urgent-text (mkRgb "base08");
          };

          window = {
            # additions over stylix: the launcher's agreed geometry
            width = rasiLiteral "600px";
            location = rasiLiteral "center";
            background-color = rasiLiteral "@background";
          };

          message.border-color = rasiLiteral "@separatorcolor";

          textbox.text-color = rasiLiteral "@base-text";

          listview = {
            # addition over stylix: the launcher's agreed row count
            lines = 10;
            border-color = rasiLiteral "@separatorcolor";
          };

          element-text = {
            background-color = rasiLiteral "inherit";
            text-color = rasiLiteral "inherit";
          };

          element-icon = {
            background-color = rasiLiteral "inherit";
            text-color = rasiLiteral "inherit";
          };

          "element normal.normal" = {
            background-color = rasiLiteral "@normal-background";
            text-color = rasiLiteral "@normal-text";
          };
          "element normal.urgent" = {
            background-color = rasiLiteral "@urgent-background";
            text-color = rasiLiteral "@urgent-text";
          };
          "element normal.active" = {
            background-color = rasiLiteral "@active-background";
            text-color = rasiLiteral "@active-text";
          };

          "element selected.normal" = {
            background-color = rasiLiteral "@selected-normal-background";
            text-color = rasiLiteral "@selected-normal-text";
          };
          "element selected.urgent" = {
            background-color = rasiLiteral "@selected-urgent-background";
            text-color = rasiLiteral "@selected-urgent-text";
          };
          "element selected.active" = {
            background-color = rasiLiteral "@selected-active-background";
            text-color = rasiLiteral "@selected-active-text";
          };

          "element alternate.normal" = {
            background-color = rasiLiteral "@alternate-normal-background";
            text-color = rasiLiteral "@alternate-normal-text";
          };
          "element alternate.urgent" = {
            background-color = rasiLiteral "@alternate-urgent-background";
            text-color = rasiLiteral "@alternate-urgent-text";
          };
          "element alternate.active" = {
            background-color = rasiLiteral "@alternate-active-background";
            text-color = rasiLiteral "@alternate-active-text";
          };

          scrollbar.handle-color = rasiLiteral "@normal-foreground";
          sidebar.border-color = rasiLiteral "@separatorcolor";
          button.text-color = rasiLiteral "@normal-text";
          "button selected" = {
            background-color = rasiLiteral "@selected-normal-background";
            text-color = rasiLiteral "@selected-normal-text";
          };

          inputbar.text-color = rasiLiteral "@normal-text";
          case-indicator.text-color = rasiLiteral "@normal-text";
          entry.text-color = rasiLiteral "@normal-text";
          prompt.text-color = rasiLiteral "@normal-text";

          textbox-prompt-colon.text-color = rasiLiteral "inherit";
        };
    };
  };

  # greetd display manager: the initial_session auto-logs the user straight
  # into dwm at boot (startx brings X up via the NixOS-generated xserverrc);
  # after the session ends, tuigreet shows the session picker as fallback.
  # (getty autologin was tried instead but applies to every tty)
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session";
        user = "greeter";
      };
      initial_session = {
        command = "${dwm-session}/bin/dwm-session";
        user = mainUser;
      };
    };
  };

  systemd.user.targets.dwm-session = {
    description = "dwm X11 session";
    documentation = [ "man:systemd.special(7)" ];
    bindsTo = [ "graphical-session.target" ];
    wants = [
      "graphical-session-pre.target"
      "xdg-desktop-autostart.target"
    ];
    after = [ "graphical-session-pre.target" ];
    before = [ "xdg-desktop-autostart.target" ];
  };

  # Random wallpaper from the repo collection, rotated every 10 minutes.
  systemd.user.services.set-wallpaper = {
    description = "Set a random wallpaper with feh";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.feh}/bin/feh --bg-fill --randomize --no-fehbg ${../../../../wallpapers}";
    };
  };
  systemd.user.timers.set-wallpaper = {
    description = "Rotate the wallpaper every 10 minutes";
    wantedBy = [ "dwm-session.target" ];
    timerConfig = {
      OnBootSec = "5s";
      OnUnitActiveSec = "10min";
      Unit = "set-wallpaper.service";
    };
  };

  security.polkit.enable = true;
  # required by home.pointerCursor.enable (gtk-qt.nix)
  programs.dconf.enable = true;

  # nm-applet needs a Secret Service implementation to store Wi-Fi
  # credentials
  services.gnome.gnome-keyring.enable = true;

  # Window manager only sessions (unlike DEs) don't handle XDG
  # autostart files, so force them to run the service
  services.xserver.desktopManager.runXdgAutostartIfNone = true;
}
