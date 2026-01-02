{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    ../../../modules/home/rutrum.nix
  ];

  me = {
    gui.enable = true;
    gaming.enable = true;
  };

  programs.zed-editor = {
    enable = true;
    installRemoteServer = true;
  };

  home.packages = with pkgs; [
    mdadm # for raid
    immich-cli
  ];
}
