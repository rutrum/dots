{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    ../modules/home/rutrum.nix
    ./modules/games.nix
  ];

  me.ui.enable = lib.mkForce true;

  # for nvidia drivers
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    mdadm # for raid
  ];
}
