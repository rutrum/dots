{
  pkgs,
  lib,
  inputs,
  ...
}: {
  _module.args.inputs = inputs; # this is huge
  imports = [
    ../modules/home/rutrum.nix

    ./modules/production/3d.nix
    ./modules/production/video.nix
    ./modules/production/photo.nix
    ./modules/production/office.nix

    ./modules/games.nix
    ./modules/zed.nix

    ./modules/reading.nix
  ];

  me.ui.enable = lib.mkForce true;

  xdg.mimeApps = {
    enable = false;
    defaultApplications = {
      "application/pdf" = "zathura.desktop";
    };
  };

  nixpkgs.config.allowUnfree = true;

  # soon
  #services.local-ai = {
  #  enable = true;
  #};

  home.packages = let
    stable-packages = with pkgs; [
      # graphical applications
      thunderbird
      protonmail-bridge-gui
      simple-scan
      nextcloud-client

      local-ai

      # dont exist yet with nixpkgs, but cargo install works
      #vtracer toml-cli ytop checkexec
      discord

      rustdesk
    ];
    unstable-packages = with inputs.nixpkgs-unstable.legacyPackages.x86_64-linux; [
      qbittorrent
      flameshot # x only?
    ];
  in
    stable-packages ++ unstable-packages;
}
