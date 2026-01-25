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

        #userSettings = {
        #  base_keymap = "VSCode";
        #  buffer_font_size = 14;
        #  buffer_font_family = "IosevkaTerm Nerd Font";
        #  buffer_line_height = "comfortable";
        #  vim_mode = true;
        #  theme = {
        #    mode = "system";
        #    light = "Catppuccin Latte";
        #    dark = "Catppuccin Mocha";
        #  };
        #  features = {
        #    copilot = false;
        #  };
        #  telemetry.metrics = false;
        #  language_models.openai_compatible.localai = {
        #    api_url = "http://192.168.50.3:8096";
        #    available_models = [
        #      {
        #        name = "qwen3-8b";
        #        display_name = "qwen3-8b";
        #        max_tokens = 32768;
        #      }
        #    ];
        #  };
        #};
      };
    };
  };
}
