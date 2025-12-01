{...}: {
  services.syncthing = {
    enable = true;
    user = "rutrum";
    dataDir = "/home/rutrum/sync";
    openDefaultPorts = true;
    settings = {
      folders = {
        notes = {
          id = "mqkjy-xoe93";
          path = "/mnt/barracuda/notes";
          devices = ["pixel7" "rumprism"];
        };
      };
    };
  };
}
