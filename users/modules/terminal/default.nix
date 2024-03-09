{ pkgs, ... }:
{
  imports = [
    ./alacritty.nix
    ./urxvt.nix
  ];

  home.packages = with pkgs; [
    nerdfonts
    noto-fonts-emoji
    iosevka-bin
  ];
}
