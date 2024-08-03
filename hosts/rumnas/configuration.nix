# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../modules/nix.nix
      ../modules/hardware/8bitdo.nix
      ../modules/ssh_server.nix
      ../modules/docker.nix
      ../modules/rustdesk_server.nix
      ../modules/rustdesk_client.nix
      ../modules/heimdall.nix
      ../modules/dashy.nix
      ../modules/nvidia.nix
      ../modules/adguard-home.nix
      ../modules/home-assistant.nix
      ../modules/tailscale.nix
      ../modules/games.nix
      ../modules/nocodb.nix
      ../modules/ai.nix
      ../modules/tabby.nix
    ];

  heimdall.port = 8081;
  dashy.port = 80;

  # put this somewhere, required for BAR and openscad
  services.flatpak.enable = true;

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

  networking.hostName = "rumnas";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  fileSystems = {
    #"/mnt/vault" = { 
    #  device = "/dev/md127";
    #  fsType = "btrfs";
    #};
  };

  # Enable networking
  networking.networkmanager.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false;

  networking.firewall.enable = false; # remove this sometime?

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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.rutrum = {
    isNormalUser = true;
    description = "rutrum";
    extraGroups = [ "docker" "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  # Enable automatic login for the user.
  services.getty.autologinUser = "rutrum";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    git
    home-manager
    qjoypad
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
