{ terminal }:
let 
  mod = "Mod4";
in {
  enable = true;
  extraConfig = ''
  '';
  keybinds = {
    "${mod}-Return" = "spawn ${terminal}";
    Mod-Shift-e spawn /home/rutrum/scripts/power.sh
hc keybind $Mod-Shift-r reload
hc keybind $Mod-Shift-q close
hc keybind $Mod-Return spawn urxvt

  };
  mousebinds = {
    
  };
  settings = {

  };
  tags = {

  };
}
