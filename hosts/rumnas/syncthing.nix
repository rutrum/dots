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
          path = "/mnt/raid/homes/rutrum/notes";
          devices = ["pixel7" "rumtower" "rumprism"];
        };
      };
    };
  };
}
