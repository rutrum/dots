{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    ./rutrum.nix

    ./modules/cli
    ./modules/ssh.nix
    ./modules/games.nix
    ./modules/joystick.nix
    ./modules/fonts.nix
    ./modules/terminal

    ./modules/browser.nix
  ];

  me.ui.enable = lib.mkForce true;

  # for nvidia drivers
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    mdadm # for raid
  ];
}
