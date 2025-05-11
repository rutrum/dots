# Edit this configuration file to define what should be installed on your system.  Help is available in the configuration.nix(5) man page and in the NixOS
# manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../system.nix
    ./hardware-configuration.nix
    ./borg.nix

    ../modules/gnome.nix
    ../modules/gaming.nix

    ../modules/printing.nix


    ../modules/docker.nix
    ../modules/services/jellyfin.nix
    ../modules/services/immich.nix
    ../modules/services/paperless.nix
    ../modules/services/firefly.nix

    ../modules/hardware/nvidia.nix
    ../modules/hardware/8bitdo.nix
    ../modules/hardware/mouse.nix
    ../modules/qmk.nix
  ];
  # cosmic test
  #nix.settings = {
  #  substituters = [ "https://cosmic.cachix.org/" ];
  #  trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
  #};
  #services = {
  #  desktopManager.cosmic.enable = true;
  #  displayManager.cosmic-greeter.enable = true;
  #};
  #hardware.pulseaudio.enable = false;

  services = {
    postgresql = {
      enable = true;
      ensureDatabases = [ "health" ];
      ensureUsers = [
        {
          name = "grafana";
        }
        {
          name = "admin";
          ensureClauses.superuser = true;
        }
      ];
      enableTCPIP = true;
      authentication = ''
        #type  database  DBuser  origin-address   auth-method
        local  all       all                      trust
        host   all       all     100.0.0.0/8      trust       # tailscale
        host   all       all     192.168.50.0/24  trust       # local network
      '';
      initialScript = pkgs.writeText "init-sql-script" ''
        ALTER USER grafana WITH PASSWORD 'grafana';
      '';
    };
    postgresqlBackup = {
      enable = true;
    };
  };

  services.tailscale = {
    useRoutingFeatures = "server";
    extraUpFlags = [
      "--advertise-exit-node" # allow clients to route traffic through nas
      "--advertise-routes=192.168.50.0/24"
    ];
  };

  services.ollama = let 
    unstable-unfree = import inputs.nixpkgs-unstable {
      system = "x86_64-linux";
      config.allowUnfree = true;
    };
  in {
    package = unstable-unfree.ollama;
    host = "0.0.0.0";
    port = 11434;
    enable = true;
    acceleration = "cuda";
  };

  services.prometheus = {
    enable = true;

    exporters = {
      node = {
        enable = true;
        port = 9000;
        openFirewall = true;
        enabledCollectors = [
          "logind"
          "systemd"
        ];
      };
    };

    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [
          {
            targets = ["localhost:9000"];
          }
        ];
      }
    ];
  };

  networking.hostName = "rumtower";

  virtualisation.waydroid.enable = true;

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark; # UI application
  };

  # Fonts
  # This should be a module
  fonts.fontDir.enable = true;

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

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;
  systemd.services.NetworkManager-ensure-profiles.after = ["NetworkManager.service"];
  systemd.services.NetworkManager-wait-online.enable = false;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  environment.systemPackages = with pkgs; [
    beets
  ];

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

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

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
