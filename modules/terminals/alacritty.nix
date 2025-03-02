{ config, lib, pkgs, alacritty-themes, colorscheme, ... }:

let
  cfg = config.debling.alacritty;
in
{
  options.debling.alacritty = {
    enable = lib.mkEnableOption "Enable alacritty program with custom settings";
  };

  config.programs.alacritty = lib.mkIf cfg.enable {
    enable = true;
    settings =
      let
        generic_setting = {
          general = {
            import = [
              "${alacritty-themes}/themes/${builtins.replaceStrings ["-"] ["_"] colorscheme.name}.toml"
            ];

            ipc_socket = false;
            live_config_reload = true;
          };

          scrolling = {
            history = 0; # history is already provided by tmux
          };

          font = {
            normal = {
              family = "JetBrainsMono Nerd Font";
              style = "Light";
            };
            size = 14;
          };

          # colors.primary.foreground = "#556b72";
        };

        macos_specific = {
          window = {
            decorations = "buttonless";
            option_as_alt = "OnlyLeft";

            padding = {
              x = 10;
              y = 6;
            };
          };
        };
      in
      pkgs.lib.mkMerge (
        [ generic_setting ]
        ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
          macos_specific
        ]
      );
  };
}
