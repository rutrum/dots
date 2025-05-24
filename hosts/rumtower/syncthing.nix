{...}: {
  services.syncthing = {
    enable = true;
    user = "rutrum";
    dataDir = "/home/rutrum/sync";
    openDefaultPorts = true;
    settings = {
      folders = {
        music = {
          id = "pcmtp-7hjbs";
          path = "/mnt/barracuda/media/music";
          type = "sendonly";
          devices = ["rumbeta"];
        };
        photos = {
          id = "pixel_6a_bde5-photos";
          path = "/mnt/barracuda/home_media/pictures/pixel6a_camera";
          type = "receiveonly";
          devices = ["rumbeta"];
        };
        notes = {
          id = "mqkjy-xoe93";
          path = "/mnt/barracuda/notes";
          devices = ["rumbeta" "rumprism"];
        };
      };
    };
  };
}
