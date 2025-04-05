{ pkgs, ... }:
{
  programs.zed-editor = {
    enable = true;
    extensions = ["nix" "justfile" "toml" "catppuccin" "typst"];

    userSettings = {
      base_keymap = "VSCode";
      vim_mode = true;
      theme = {
        mode = "system";
        light = "Catppuccin Latte";
        dark = "Catppuccin Mocha";
      };
      features = {
        copilot = false;
      };
      telemetry.metrics = false;
    };
  };
}
