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
      zed-editor = {
        enable = true;
        package = perSystem.nixpkgs-unstable.zed-editor;
        extensions = ["nix" "justfile" "toml" "catppuccin" "typst" "html"];
      };
    };
  };
}
