{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [
    ./ide.nix
    ./browser.nix
  ];

  options.me = {
    gui.enable = lib.mkEnableOption "gui";
    gaming.enable = lib.mkEnableOption "gaming";
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
        bitwarden-desktop
        sxiv
        rxvt-unicode
        nextcloud-client
      ];

      catppuccin.alacritty.enable = true;
      programs.alacritty = {
        enable = true;
        settings = {
          window = {
            opacity = 0.85;
            padding.x = 24;
            padding.y = 24;
          };
          font = {
            normal.family = "Iosevka Nerd Font";
          };
          keyboard.bindings = [
            {
              key = "I";
              mods = "Alt";
              action = "IncreaseFontSize";
            }
            {
              key = "U";
              mods = "Alt";
              action = "DecreaseFontSize";
            }
          ];
        };
      };
    }

    # gaming module
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

      #services.flatpak.packages = [
      #  "flathub:app/info.beyondallreason.bar//stable"
      #];
    })
  ]);
}
