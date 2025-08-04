{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./urxvt.nix
    ./alacritty.nix
  ];

  home.packages = with pkgs; [
    pkgs.nerd-fonts.iosevka
    pkgs.nerd-fonts.iosevka-term
    pkgs.nerd-fonts.iosevka-term-slab
    noto-fonts-emoji
  ];
}
