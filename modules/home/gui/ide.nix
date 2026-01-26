{
  pkgs,
  lib,
  config,
  inputs,
  perSystem,
  ...
}: {
  config = lib.mkIf config.me.gui.enable {
    programs = {
      vscode = {
        enable = true;
        #package = pkgs.vscodium-fhs;
        package = pkgs.vscode-fhs;
        profiles.default = {
          extensions = with pkgs.vscode-extensions; [
            continue.continue
          ];
        };
      };

      zed-editor = {
        enable = true;
        package = perSystem.nixpkgs-unstable.zed-editor;
        extensions = ["nix" "justfile" "toml" "catppuccin" "typst" "html"];
      };
    };
  };
}
