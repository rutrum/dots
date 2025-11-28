{
  pkgs,
  lib,
  inputs,
  ...
}: {
  _module.args.inputs = inputs; # this is huge
  imports = [
    ../../../modules/home/rutrum.nix
    ../../../users/modules/games.nix
  ];

  me.ui.enable = lib.mkForce true;

  xdg.mimeApps = {
    enable = false;
    defaultApplications = {
      "application/pdf" = "zathura.desktop";
    };
  };

  nixpkgs.config.allowUnfree = true;

  services.flatpak.packages = [
    "flathub-beta:app/org.openscad.OpenSCAD//beta"
  ];

  home.packages = let
    stable-packages = with pkgs; [
      # graphical applications
      thunderbird
      protonmail-bridge-gui
      simple-scan
      nextcloud-client

      # dont exist yet with nixpkgs, but cargo install works
      #vtracer toml-cli ytop checkexec
      discord

      rustdesk

      # image editing
      gthumb
      upscayl # ai upscaler
      krita
      gimp3

      # 3d printing
      orca-slicer

      # office
      drawio
      libreoffice

      # video production
      losslesscut-bin
      obs-studio

      # reading
      zotero
      calibre
    ];
    unstable-packages = with inputs.nixpkgs-unstable.legacyPackages.x86_64-linux; [
      qbittorrent
    ];
  in
    stable-packages ++ unstable-packages;
}
