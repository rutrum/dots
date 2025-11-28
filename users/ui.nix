{
  lib,
  config,
  pkgs,
  ...
}: {
  # user configuration for all UIs

  imports = [
    ./modules/terminal
    ./modules/browser.nix
    ./modules/fonts.nix
  ];

  options.me = {
    ui.enable = lib.mkEnableOption "ui";
  };

  config = lib.mkIf config.me.ui.enable {
    home.packages = let
      stable-packages = with pkgs; [
        vscodium # why not both?
        localsend
        zathura
        vlc
        anki-bin
        bitwarden
        sxiv
        rxvt-unicode
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
