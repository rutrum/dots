{
  lib,
  config,
  pkgs,
  ...
}: {
  # user configuration for all UIs

  imports = [
    ./modules/terminal.nix
    ./modules/browser.nix
    ./modules/ide.nix
  ];

  options.me = {
    ui.enable = lib.mkEnableOption "ui";
  };

  config = lib.mkIf config.me.ui.enable {
    fonts.fontconfig.enable = true;

    home.packages = let
      stable-packages = with pkgs; [
        font-manager
        vscodium # why not both?
        localsend
        zathura
        vlc
        anki-bin
        bitwarden
        sxiv
        rxvt-unicode

        # database client
        dbeaver-bin

        # database drivers for common databases
        sqlite-jdbc
        postgresql_jdbc
        mysql_jdbc
      ];
      unstable-packages = [];
    in
      stable-packages ++ unstable-packages;

    programs.vscode = {
      enable = true;
      #package = pkgs.vscodium-fhs;
      package = pkgs.vscode-fhs;
      profiles.default = {
        extensions = with pkgs.vscode-extensions; [
          continue.continue
        ];
      };
    };
  };
}
