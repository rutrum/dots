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
    # wayland cli tools
    wl-clipboard

    # graphical applications
    simple-scan

    # dont exist yet with nixpkgs, but cargo install works
    #vtracer toml-cli ytop checkexec
    discord

    # nixpkgs' default `electron` is built from Chromium source. Use the
    # prebuilt binary so a rebuild doesn't compile Chromium from scratch.
    # Keep the major version in sync with pkgs.electron.
    (affine.override {electron = pkgs.electron_43-bin;})

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
    # see note above re: prebuilt electron
    (drawio.override {electron = pkgs.electron_43-bin;})
    libreoffice

    # video production
    losslesscut-bin
    obs-studio
    audacity

    # reading
    calibre

    # databases
    dbeaver-bin
    sqlite-jdbc
    postgresql_jdbc
    mysql_jdbc
  ];
}
