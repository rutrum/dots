{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [
    ./ide.nix
    ./browser.nix
    ./terminal.nix
  ];

  options.me = {
    gui.enable = lib.mkEnableOption "gui";
    gaming.enable = lib.mkEnableOption "gaming";
    databases.enable = lib.mkEnableOption "databases";
  };

  config = lib.mkIf config.me.gui.enable (lib.mkMerge [
    {
      fonts.fontconfig.enable = true;

      home.packages = with pkgs; [
        font-manager
        vscodium
        localsend
        zathura
        vlc
        anki-bin
        bitwarden
        sxiv
        rxvt-unicode
        nextcloud-client
      ];
    }

    (lib.mkIf config.me.databases.enable {
      home.packages = with pkgs; [
        dbeaver-bin
        sqlite-jdbc
        postgresql_jdbc
        mysql_jdbc
      ];
    })

    (lib.mkIf config.me.gaming.enable {
      home.packages = with pkgs; [
        superTuxKart
        mindustry
        xonotic
        lumafly # hallow knight mod manager
        prismlauncher # minecraft launcher
        airshipper # game launcher for veloren
        archipelago # utilities for archipelago servers
      ];

      services.flatpak.packages = [
        "flathub:app/info.beyondallreason.bar//stable"
      ];
    })
  ]);
}
