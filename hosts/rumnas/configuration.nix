# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, ... }:

{
  imports = [ 
    ../system.nix
    ./hardware-configuration.nix

    ../modules/gaming.nix

    ../modules/docker.nix
    ../modules/services/tabby.nix
    ../modules/services/home-assistant.nix
    ../modules/services/heimdall.nix
    ../modules/services/rustdesk.nix
    ../modules/services/adguard-home.nix
    ../modules/services/dashy.nix
    ../modules/services/nocodb.nix
    ../modules/services/grafana.nix
    #../modules/services/nextcloud.nix

    ../modules/hardware/nvidia.nix
    ../modules/hardware/8bitdo.nix
  ];

  networking.hostName = "rumnas";

  heimdall.port = 8083;
  dashy.port = 80;

  services.openssh.enable = true;

  # TODO: configure caddy for web services

  # allow x forwarding
  programs.ssh.forwardX11 = true;

  # backups?
  services.borgbackup.repos.paperless = {
    path = "/mnt/vault/backups/paperless";
    authorizedKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIb4sr8jfAagDEYJQg1Xa9WN1i+jQFzEnSvU/e1X4oed rutrum@rumtower"
    ];
  };

  # stop sleeping/hibernating/suspend
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  fileSystems = {
    "/mnt/raid" = { 
      device = "/dev/md127";
      fsType = "btrfs";
    };
  };

  # raid
  boot.swraid.enable = true;

  # Enable networking
  networking.networkmanager.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false;

  networking.firewall.enable = false; # remove this sometime? please uwu?

  # Configure keymap in X11
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    #desktopManager.gnome.enable = true;
    desktopManager.cinnamon.enable = true;
    layout = "us";
    xkbVariant = "";
  };

  services.cinnamon.apps.enable = true;

  #services.gnome.core-utilities.enable =  false;
  # consider manually adding back certain utilities

  #user.users.borg = {
  #  isSystemUser = true;
  #  description = "Account for borgmatic";
  #};

  # Enable automatic login for the user.
  services.getty.autologinUser = "rutrum";

  environment.systemPackages = with pkgs; [];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
