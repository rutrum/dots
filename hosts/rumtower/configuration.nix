# Edit this configuration file to define what should be installed on your system.  Help is available in the configuration.nix(5) man page and in the NixOS 
# manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../modules/gnome.nix
    ../modules/nvidia.nix
    ../modules/games.nix

    ../modules/nix.nix
    ../modules/paperless.nix
    ../modules/adguard-home.nix
    ../modules/printing.nix
    ../modules/firefly.nix
    ../modules/docker.nix
    ../modules/jellyfin.nix
    ../modules/8bitdo.nix

    ../modules/mouse.nix
    ../modules/tailscale.nix
    ../modules/rustdesk_client.nix
    ../modules/tabby.nix
  ];

  networking.hostName = "rumtower";

  # Fonts
  # This should be a module
  fonts.fontDir.enable = true;

  # syncthing
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
          devices = [ "rumbeta" ];
        };
        photos = {
          id = "pixel_6a_bde5-photos";
          path = "/mnt/barracuda/media/pictures/pixel6a_camera";
          type = "receiveonly";
          devices = [ "rumbeta" ];
        };
        #roms = {
        #};
        notes = {
          id = "mqkjy-xoe93";
          path = "/mnt/barracuda/notes";
          devices = [ "rumbeta" ];
        };
      };
      devices = {
        rumbeta.id = "3FRVZJQ-RG6QI2E-B2WIQ4W-7MIJ2LB-ZCHLSI4-WQVTTUS-SRFAOUS-JUAEVAI";
      };
    };
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;
  systemd.services.NetworkManager-ensure-profiles.after = [ "NetworkManager.service" ];
  systemd.services.NetworkManager-wait-online.enable = false;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  services.flatpak.enable = true;

  fileSystems = {
    #"/".device = "/dev/nvme0n1";
    "/mnt/barracuda" = {
      device = "/dev/sda";
      fsType = "ext4";
    };

    #"/mnt/nfs_dave" = {
    #  device = "192.168.50.90:/dave";
    #  fsType = "nfs";
    #  options = [ "x-systemd.automount" "noauto" ];
    #};
  };

  # Set your time zone.
  time.timeZone = "America/Indiana/Indianapolis";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.mullvad-vpn.enable = true;

  # Configure keymap in X11
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    desktopManager.xfce.enable = true;
    xkb.layout = "us";
    xkb.variant = "";
  };

  #services.gnome.core-utilities.enable =  false;
  # consider manually adding back certain utilities


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.rutrum = {
    isNormalUser = true;
    description = "rutrum";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    neovim git home-manager
  ];

  # List services that you want to enable:
  networking.firewall.enable = false;
  networking.nftables.enable = true;


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
