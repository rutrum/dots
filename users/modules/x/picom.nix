{
  services.picom = {
    enable = false;
    settings = {
      # fix for nvidia: https://nixos.wiki/wiki/Nvidia
      unredir-if-possible = false;
      backend = "xrender"; # this might be a problem for my laptop
      vsync = true;

      shadow = true;

      shadow-radius = 12;
      shadow-opacity = 0.3;
      shadow-offset-x = 0;
      shadow-offset-y = 0;
      shadow-exclude = [
        "name = 'Notification'"
      ];

      blur = {
        method = "gaussian";
        size = 10;
        deviation = 15.0;
      };
    };
  };
}
