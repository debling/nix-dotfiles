{ config, lib, pkgs, mainUser, nix-colors, colorscheme, ... }:

{
  imports = [ ../common.nix ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  programs = {
    dconf.enable = true;
    xwayland.enable = true;
  };

  security = {
    polkit.enable = true;
  };

  services.graphical-desktop.enable = true;

  home-manager.users.${mainUser} = {
    wayland.windowManager.river = {
      enable = true;
      settings = with colorscheme.palette; {
        rule-add = {
          "-app-id" =
            let
              intFromBinStr = str:
                lib.pipe str [
                  lib.stringToCharacters
                  lib.reverseList
                  (map lib.toInt)
                  (lib.foldl (acc: digit: acc * 2 + digit) 0)
                ];
            in
            {
              emacs = [ "ssd" { tags = intFromBinStr "100000000"; } ]; # ws 1
              Slack = { tags = intFromBinStr "010000000"; }; # ws 2
              zen-beta = [ "ssd" { tags = intFromBinStr "001000000"; } ];
              spotify = { tags = intFromBinStr "000000001"; }; # only workspace 9
            };
        };

        map = {
          normal = {
            "Super+Shift Return" = "spawn footclient";
            "Super Space" = "spawn fuzzel";
            "Super Q" = "close";
            "Super Y" = "spawn 'cliphist list | fuzzel --dmenu | cliphist decode | wl-copy'";
          };
        };

        spawn = [
          "yambar"
          "zen"
          "emacs"
          "spotify"
          "slack"
        ];

        default-layout = "rivertile";
        keyboard-layout = "us";
        background-color = "0x${base00}";
        border-color-unfocused = "0x${base01}";
        border-color-focused = "0x${base0A}";
      };
      extraConfig = /* sh */ ''
        # Super+Shift+E to exit river
        riverctl map normal Super+Shift E exit

        # Super+J and Super+K to focus the next/previous view in the layout stack
        riverctl map normal Super J focus-view next
        riverctl map normal Super K focus-view previous

        # Super+Shift+J and Super+Shift+K to swap the focused view with the next/previous
        # view in the layout stack
        riverctl map normal Super+Shift J swap next
        riverctl map normal Super+Shift K swap previous

        # Super+Period and Super+Comma to focus the next/previous output
        riverctl map normal Super Period focus-output next
        riverctl map normal Super Comma focus-output previous

        # Super+Shift+{Period,Comma} to send the focused view to the next/previous output
        riverctl map normal Super+Shift Period send-to-output next
        riverctl map normal Super+Shift Comma send-to-output previous

        # Super+Return to bump the focused view to the top of the layout stack
        riverctl map normal Super Return zoom

        # Super+H and Super+L to decrease/increase the main ratio of rivertile(1)
        riverctl map normal Super H send-layout-cmd rivertile "main-ratio -0.05"
        riverctl map normal Super L send-layout-cmd rivertile "main-ratio +0.05"

        # Super+Shift+H and Super+Shift+L to increment/decrement the main count of rivertile(1)
        riverctl map normal Super+Shift H send-layout-cmd rivertile "main-count +1"
        riverctl map normal Super+Shift L send-layout-cmd rivertile "main-count -1"

        # Super+Alt+{H,J,K,L} to move views
        riverctl map normal Super+Alt H move left 100
        riverctl map normal Super+Alt J move down 100
        riverctl map normal Super+Alt K move up 100
        riverctl map normal Super+Alt L move right 100

        # Super+Alt+Control+{H,J,K,L} to snap views to screen edges
        riverctl map normal Super+Alt+Control H snap left
        riverctl map normal Super+Alt+Control J snap down
        riverctl map normal Super+Alt+Control K snap up
        riverctl map normal Super+Alt+Control L snap right

        # Super+Alt+Shift+{H,J,K,L} to resize views
        riverctl map normal Super+Alt+Shift H resize horizontal -100
        riverctl map normal Super+Alt+Shift J resize vertical 100
        riverctl map normal Super+Alt+Shift K resize vertical -100
        riverctl map normal Super+Alt+Shift L resize horizontal 100

        # Super + Left Mouse Button to move views
        riverctl map-pointer normal Super BTN_LEFT move-view

        # Super + Right Mouse Button to resize views
        riverctl map-pointer normal Super BTN_RIGHT resize-view

        # Super + Middle Mouse Button to toggle float
        riverctl map-pointer normal Super BTN_MIDDLE toggle-float

        for i in $(seq 1 9)
        do
            tags=$((1 << ($i - 1)))

            # Super+[1-9] to focus tag [0-8]
            riverctl map normal Super $i set-focused-tags $tags

            # Super+Shift+[1-9] to tag focused view with tag [0-8]
            riverctl map normal Super+Shift $i set-view-tags $tags

            # Super+Control+[1-9] to toggle focus of tag [0-8]
            riverctl map normal Super+Control $i toggle-focused-tags $tags

            # Super+Shift+Control+[1-9] to toggle tag [0-8] of focused view
            riverctl map normal Super+Shift+Control $i toggle-view-tags $tags
        done

        # Super+0 to focus all tags
        # Super+Shift+0 to tag focused view with all tags
        all_tags=$(((1 << 32) - 1))
        riverctl map normal Super 0 set-focused-tags $all_tags
        riverctl map normal Super+Shift 0 set-view-tags $all_tags

        # Super+Space to toggle float
        riverctl map normal Super f toggle-float

        # Super+F to toggle fullscreen
        riverctl map normal Super F toggle-fullscreen

        # Super+{Up,Right,Down,Left} to change layout orientation
        riverctl map normal Super Up    send-layout-cmd rivertile "main-location top"
        riverctl map normal Super Right send-layout-cmd rivertile "main-location right"
        riverctl map normal Super Down  send-layout-cmd rivertile "main-location bottom"
        riverctl map normal Super Left  send-layout-cmd rivertile "main-location left"

        # Declare a passthrough mode. This mode has only a single mapping to return to
        # normal mode. This makes it useful for testing a nested wayland compositor
        riverctl declare-mode passthrough

        # Super+F11 to enter passthrough mode
        riverctl map normal Super F11 enter-mode passthrough

        # Super+F11 to return to normal mode
        riverctl map passthrough Super F11 enter-mode normal

        # Various media key mapping examples for both normal and locked mode which do
        # not have a modifier
        for mode in normal locked
        do
            # Eject the optical drive (well if you still have one that is)
            riverctl map $mode None XF86Eject spawn 'eject -T'

            riverctl map $mode None XF86AudioRaiseVolume  spawn 'volume set 5%+'
            riverctl map $mode None XF86AudioLowerVolume  spawn 'volume set 5%-'
            riverctl map $mode None XF86AudioMute         spawn 'wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle'

            # Control MPRIS aware media players with playerctl (https://github.com/altdesktop/playerctl)
            riverctl map $mode None XF86AudioMedia spawn 'playerctl play-pause'
            riverctl map $mode None XF86AudioPlay  spawn 'playerctl play-pause'
            riverctl map $mode None XF86AudioPrev  spawn 'playerctl previous'
            riverctl map $mode None XF86AudioNext  spawn 'playerctl next'

            # Control screen backlight brightness with brightnessctl (https://github.com/Hummer12007/brightnessctl)
            riverctl map $mode None XF86MonBrightnessUp   spawn 'brightnessctl set +5%'
            riverctl map $mode None XF86MonBrightnessDown spawn 'brightnessctl set 5%-'
        done

        # Set keyboard repeat rate
        riverctl set-repeat 50 300

        # Make all views with an app-id that starts with "float" and title "foo" start floating.
        riverctl rule-add -app-id 'float*' -title 'foo' float

        # Make all views with app-id "bar" and any title use client-side decorations
        riverctl rule-add -app-id "bar" csd

        rivertile -view-padding 6 -outer-padding 6 &

        riverctl map normal Alt+Shift 4  spawn  screenshot
        riverctl map normal Alt+Shift 5  spawn  kooha

        riverctl map $mode None XF86MonBrightnessDown spawn 'brightnessctl set 5%-'

        # x1-touchpad
        riverctl input pointer-1739-0-Synaptics_TM3289-021 scroll-factor  0.3
        riverctl input pointer-1739-0-Synaptics_TM3289-021 natural-scroll enabled
        riverctl input pointer-1739-0-Synaptics_TM3289-021 tap            enabled

        riverctl input pointer-2-10-TPPS/2_Elan_TrackPoint pointer-accel  1.5

        riverctl input pointer-2362-9505-USB_OPTICAL_MOUSE natural-scroll enabled
      '';
    };


    programs = {
      yambar = {
        enable = true;
        settings = {
          bar = with colorscheme.palette; {
            margin = 6;
            height = 26;
            location = "top";
            foreground = "FFFFFFFF";
            background = "${base00}bb";

            left = [
              {
                river =
                  let
                    workspaces = lib.lists.range 1 10;
                    wsFn = id: { "id == ${toString id}".string.text = id; };
                    workspaceTemplate = {
                      left-margin = 10;
                      right-margin = 13;
                      conditions = lib.fold (attr: acc: acc // attr) { } (map wsFn workspaces);
                    };
                    selectedColor = "${base02}ff";
                    occupiedUnderlineColor = "${base0B}ff";
                    bgDefault = {
                      stack = [
                        { background.color = selectedColor; }
                        {
                          underline = { size = 4; color = occupiedUnderlineColor; };
                        }
                      ];
                    };
                  in
                  {
                    content.map = {
                      on-click = {
                        left = "sh -c \"riverctl set-focused-tags $((1 << ({id} - 1)))\"";
                        right = "sh -c \"riverctl toggle-focused-tags $((1 << ({id} -1)))\"";
                        middle = "sh -c \"riverctl toggle-view-tags $((1 << ({id} -1)))\"";
                      };
                      conditions = {
                        "state == urgent".map = workspaceTemplate // {
                          deco.background.color = "${base09}ff";
                        };
                        "state == focused".map = workspaceTemplate // { deco = bgDefault; };
                        "state == visible && ~occupied".map = workspaceTemplate;
                        "state == visible && occupied".map = workspaceTemplate // { deco = bgDefault; };
                        "state == unfocused && occupied".map = workspaceTemplate;
                        "state == invisible && ~occupied".empty = { };
                        "state == invisible && occupied".map = workspaceTemplate;
                      };
                    };
                  };
              }
            ];

            center = [
              {
                foreign-toplevel.content.map.conditions = {
                  "~activated".empty = { };
                  activated = [
                    { string = { text = "{app-id}"; foreground = "${base0B}ff"; }; }
                    { string.text = ": {title}"; }
                  ];
                };
              }
            ];

            right = [
              {
                network = {
                  poll-interval = 1000;
                  content.map.conditions."name == wlp2s0".map =
                    let
                      base = { margin = 10; };
                    in
                    {
                      default = { string = { text = "  "; foreground = "ffffff66"; } // base; };
                      conditions = {
                        "state == down" = { string = { text = "  "; foreground = "ff0000ff"; } // base; };
                        "state == up" = [
                          { string = { text = "  "; }; }
                          { string = { text = "{ssid} {dl-speed:mb}/{ul-speed:mb} Mb/s"; } // base; }
                        ];
                      };
                    };
                };
              }

              {
                battery = {
                  name = "BAT0";
                  poll-interval = 30000;
                  content.map.conditions =
                    let
                      states = [
                        { string = { text = "   "; foreground = "ff0000ff"; }; }
                        { string = { text = "   "; foreground = "ffa600ff"; }; }
                        { string.text = "   "; }
                        { string.text = "   "; }
                        { string.text = "   "; }
                        { string.text = "   "; }
                        { string.text = "   "; }
                        { string.text = "   "; }
                        { string.text = "   "; }
                        { string.text = "   "; }
                        { string = { text = "   "; foreground = "00ff00ff"; }; }
                      ];
                      template = [
                        { ramp = { tag = "capacity"; items = states; }; }
                        { string.text = "{capacity}% {estimate}"; }
                      ];
                    in
                    {
                      "state == unknown" = template;
                      "state == discharging" = template;
                      "state == \"not charging\"" = template;
                      "state == charging" = [
                        { string = { text = "  "; foreground = "00ff00ff"; }; }
                        { string.text = "{capacity}% {estimate}"; }
                      ];
                      "state == full" = [
                        { string = { text = "  "; foreground = "00ff00ff"; }; }
                        { string.text = "{capacity}% full"; }
                      ];
                    };

                };
              }
              {
                backlight = {
                  name = "intel_backlight";
                  content = [{ string = { text = "  {percent}%"; margin = 10; }; }];
                };
              }
              {
                clock = {
                  time-format = "  %H:%M";
                  content = [{ string.text = "{date} {time}"; }];
                };
              }
            ];
          };
        };
      };

      fuzzel = {
        enable = true;
        settings = {
          main = {
            terminal = "${pkgs.foot}/bin/footclient";
            font = "monospace:size=16";
            dpi-aware = false;
            show-actions = true;
            list-executables-in-path = true;
            lines = 10;
          };
          border = {
            radius = 0;
            width = 3;
          };
          colors = with colorscheme.palette; {
            background = "${base00}ff";
            text = "${base05}ff";
            match = "${base0D}ff";
            selection = "${base03}ff";
            selection-text = "${base06}ff";
            selection-match = "${base0D}ff";
            border = "${base05}ff";
          };
        };
      };
    };
  };
}
