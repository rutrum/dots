{pkgs, ...}: {
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
