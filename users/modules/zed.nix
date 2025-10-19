{pkgs, ...}: {
  programs.zed-editor = {
    enable = true;
    extensions = ["nix" "justfile" "toml" "catppuccin" "typst" "html"];

    userSettings = {
      base_keymap = "VSCode";
      buffer_font_size = 14;
      buffer_font_family = "IosevkaTerm Nerd Font";
      buffer_line_height = "standard";
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
      language_models.ollama = {
        api_url = "http://192.168.50.47:11434";
        available_models = [
          {
            name = "qwen2.5-coder:7b";
            display_name = "qwen2.5-coder:7b";
            max_tokens = 32768;
          }
        ];
      };
    };
  };
}
