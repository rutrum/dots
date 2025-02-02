{
  pkgs,
  terminal,
}: let
  mod = "Mod4";
in {
  enable = true;
  package = pkgs.herbstluftwm;
  extraConfig = ''
  '';
  keybinds = {
    "${mod}-Return" = "spawn ${terminal}";
    "${mod}-Shift-e" = "spawn /home/rutrum/scripts/power.sh";
    "${mod}-Shift-r" = "reload";
    "${mod}-Shift-q" = "close";
  };
  mousebinds = {
  };
  settings = {
  };
  # tags = { };
}
