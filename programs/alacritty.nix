{ lib, ... }:
{
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        opacity = 0.85;
        padding.x = 24;
        padding.y = 24;
      };
      font = {
        normal.family = "Iosevka Nerd Font Mono";
      };
      inherit (lib.importTOML ./catppuccin-mocha.toml) colors;
    };
  };
}
