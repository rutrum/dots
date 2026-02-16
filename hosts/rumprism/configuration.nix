{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.self.nixosModules.system
    ./hardware-configuration.nix
    inputs.self.nixosModules.printing
  ];

  networking.hostName = "rumprism";

  services.syncthing = {
    enable = true;
    user = "rutrum";
    dataDir = "/home/rutrum/sync";
    openDefaultPorts = true;
    settings = {
      folders = {
        notes = {
          id = "mqkjy-xoe93";
          path = "/home/rutrum/notes";
          devices = ["pixel7" "rumtower"];
        };
      };
    };
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      Policy = {
        AutoEnable = true;
      };
    };
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  systemd.services.NetworkManager-wait-online.enable = false;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # GPU stuff
  hardware.graphics.enable = true;

  # Enable the X11 windowing system.
  # Look into wayland display manager
  services.xserver.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.cinnamon.enable = true;

  # new wayland wm stuff
  programs.niri.enable = true;
  programs.waybar.enable = true;

  services.xserver.videoDrivers = ["modesetting"];

  services.logind.settings.Login = {
    IdleAction = "hybrid-sleep";
    IdleActionSec = "30min";
    HandlePowerKey = "ignore";
  };

  # Enable sound with pipewire.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  environment.systemPackages = with pkgs; [
    fuzzel # app launcher for wayland
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
