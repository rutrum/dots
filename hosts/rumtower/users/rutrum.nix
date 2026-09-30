{
  pkgs,
  pkgs-unstable,
  lib,
  inputs,
  perSystem,
  ...
}: {
  imports = [
    inputs.self.homeModules.rutrum
  ];

  me = {
    gui.enable = true;
    gaming.enable = true;
  };

  xdg.mimeApps = {
    enable = false;
    defaultApplications = {
      "application/pdf" = "zathura.desktop";
    };
  };

  # Joplin client via declarative-flatpak (nixpkgs joplin-desktop is broken
  # and pinned to 3.6.16; Flathub tracks the 3.7.x line the server needs).
  services.flatpak.packages = [
    "flathub:app/net.cozic.joplin_desktop//stable"
  ];

  home.packages = with pkgs; [
    # graphical applications
    thunderbird
    simple-scan
    nextcloud-client

    # dont exist yet with nixpkgs, but cargo install works
    #vtracer toml-cli ytop checkexec
    discord

    affine

    rustdesk

    forgejo-cli

    # image editing
    gthumb
    upscayl # ai upscaler
    krita
    gimp3
    inkscape

    # 3d printing
    orca-slicer

    # office
    drawio
    libreoffice

    # video production
    losslesscut-bin
    obs-studio
    audacity

    # reading
    zotero
    calibre

    # databases
    dbeaver-bin
    sqlite-jdbc
    postgresql_jdbc
    mysql_jdbc

    perSystem.openspec.default
  ];
}
