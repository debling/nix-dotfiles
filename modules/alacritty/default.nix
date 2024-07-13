{ config, lib, pkgs, alacritty-themes, ... }:

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
          import = [
            "${alacritty-themes}/themes/gruvbox_dark.toml"
          ];

          live_config_reload = true;
          ipc_socket = false;
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

          # override gruvbox_dark with the same background as gruvbox.nvim
          # see: https://github.com/ellisonleao/gruvbox.nvim/blob/6e4027ae957cddf7b193adfaec4a8f9e03b4555f/lua/gruvbox.lua#L74C18-L74C24
          colors.primary.background = "#1d2021";
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
