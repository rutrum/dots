{ ... }:
{
  programs.rofi = {
    enable = true;
    extraConfig = {
      lines = 10;
      show-icons = true;
    };
    theme = "glue_pro_blue";
  };
}
