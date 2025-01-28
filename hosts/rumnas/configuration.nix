# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, inputs, ... }:

{
  imports = [ 
    ../system.nix
    ./hardware-configuration.nix
    ./samba.nix

    #../modules/gnome.nix
    ../modules/gaming.nix

    ../modules/docker.nix
    ../modules/services/tabby.nix
    ../modules/services/home-assistant.nix
    #../modules/services/rustdesk.nix
    ../modules/services/adguard-home.nix
    ../modules/services/dashy.nix
    ../modules/services/nocodb.nix
    ../modules/services/grafana.nix
    #../modules/services/nextcloud.nix
    ../modules/services/tube-archivist.nix
    ../modules/services/llm.nix
    ../modules/services/mealie.nix
    ../modules/services/forgejo.nix

    ../modules/hardware/nvidia.nix
    ../modules/hardware/8bitdo.nix
  ];

  networking.hostName = "rumnas";

  dashy.port = 80;
  services.tailscale = {
    useRoutingFeatures = "server";
    extraUpFlags = [
      "--advertise-exit-node" # allow clients to route traffic through nas
      "--advertise-routes=192.168.50.0/24"
    ];
};

  services.openssh.enable = true;

  # TODO: configure caddy for web services

  # let's play with a local binary cache
  # https://nixos.wiki/wiki/Binary_Cache
  services.nix-serve = {
    enable = true;
    # hoping I don't need this, since it should be local?
    #secretKeyFile = "/var/cache-priv-key.pem";
  };
  networking.firewall.allowedTCPPorts = [ 5000 ];

  # allow x forwarding
  #programs.ssh.forwardX11 = true;

  # backups?
  services.borgbackup.repos.paperless = {
    path = "/mnt/vault/backups/paperless";
    authorizedKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIb4sr8jfAagDEYJQg1Xa9WN1i+jQFzEnSvU/e1X4oed rutrum@rumtower"
    ];
  };

  # stop sleeping/hibernating/suspend
  #systemd.targets.sleep.enable = false;
  #systemd.targets.suspend.enable = false;
  #systemd.targets.hibernate.enable = false;
  #systemd.targets.hybrid-sleep.enable = false;

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

  networking.firewall.enable = false; # remove this sometime? please uwu?

  #services.xserver.desktopManager.lxqt.enable = true;
  #services.xserver.desktopManager.cinnamon.enable = true;
  #services.xserver.displayManager.lightdm.enable = true;
  #services.xserver = {
  #  enable = true;
  #  displayManager.gdm.enable = true;
  #  desktopManager.gnome.enable = true;
  #  #desktopManager.cinnamon.enable = true;
  #};

  services.xserver = {
    enable = true;
    desktopManager = {
      #gnome.enable = true;
      cinnamon.enable = true;
    };
    displayManager.lightdm = {
      enable = true;
    };
  };
  services.displayManager.defaultSession = "cinnamon";
  #services.xserver.displayManager.lightdm.enable = true;
  #services.xserver.desktopManager.cinnamon.enable = true;

  #services.cinnamon.apps.enable = true;

  #services.gnome.core-utilities.enable =  false;
  # consider manually adding back certain utilities

  users = {
    users.reolink = {
      isSystemUser = true;
      description = "Account for cameras to save recordings";
      group = "reolink";
      home = "/mnt/vault/reolink";
      shell = pkgs.bashInteractive;
    };
    # normal users are part of "user" group by default
    groups.reolink = {};
  };

  # Enable automatic login for the user.
  #services.getty.autologinUser = "rutrum";

  environment.systemPackages = with pkgs; [];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
