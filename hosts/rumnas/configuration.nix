{
  pkgs,
  lib,
  inputs,
  config,
  ...
}: {
  imports = [
    inputs.vpn-confinement.nixosModules.default
    inputs.self.nixosModules.system
    ./hardware-configuration.nix
    ./fileserver.nix
    ./cache.nix
    ./openrgb.nix
    ./immich.nix
    ./adguardhome.nix
    ./qbittorrent.nix

    # containerized
    ./nocodb.nix
    ./romm.nix
    ./freshrss.nix
    ./dashy.nix
    ./home-assistant.nix

    inputs.self.nixosModules.gaming
    inputs.self.nixosModules.controller
    inputs.self.nixosModules.nvidia
    inputs.self.nixosModules.local-ai

    # ./frigate.nix
  ];

  networking.hostName = "rumnas";

  services = {
    open-webui = {
      enable = true;
      package = pkgs.open-webui;
      host = "0.0.0.0";
      port = 8080;
      openFirewall = true;
    };

    karakeep = {
      enable = false;
      browser.enable = true;
      meilisearch.enable = true;
      extraEnvironment = {
        PORT = "8090";
      };
    };

    grafana = {
      enable = true;
      settings = {
        server = {
          http_addr = "0.0.0.0";
          http_port = 3000;
          domain = "rumnas.lynx-chromatic.ts.net";
        };

        security = {
          allow_embedding = true;
          cookie_samesite = "disabled";
        };
      };
    };

    mealie = {
      enable = true;
      port = 9000;
    };

    ntfy-sh = {
      enable = true;
      settings = {
        base-url = "http://rumnas.lynx-chromatic.ts.net";
        listen-http = ":8888";
      };
    };

    tailscale = {
      useRoutingFeatures = "server";
      openFirewall = true;
      extraSetFlags = [
        "--advertise-exit-node"
        "--exit-node-allow-lan-access"
        "--advertise-routes=192.168.50.100/32"
      ];
    };
    # optimization suggested by tailscale
    # https://wiki.nixos.org/wiki/Tailscale#Optimize_the_performance_of_subnet_routers_and_exit_nodes
    networkd-dispatcher = {
      enable = true;
      rules."50-tailscale" = {
        onState = ["routable"];
        script = ''
          ${pkgs.ethtool} -K enp39s0 rx-udp-gro-forwarding on rx-gro-list off
        '';
      };
    };

    jellyfin = {
      enable = true;
      openFirewall = true;
    };
    ersatztv = {
      enable = true;
      openFirewall = true;
      environment = {
        ETV_UI_PORT = "8409";
      };
    };

    #sops.secrets = {
    #  "freshrss/password".owner = "freshrss";
    #};
    #freshrss = {
    #  enable = true;
    #  passwordFile = config.sops.secrets."freshrss/password".path;
    #  baseUrl = "http://192.168.50.3:9090";
    #  virtualHost = "192.168.50.3:9090";
    #  #webserver = "caddy";
    #};
    #caddy.virtualHosts = {
    #  "http://192.168.50.3:9090" = {
    #    serverAliases = [ "http://rumnas.lynx-chromatic.ts.net" ];
    #    extraConfig = ''
    #      reverse_proxy localhost:9090
    #    '';
    #  };
    #};

    openssh.enable = true;

    # TODO: configure caddy for web services

    # TODO: create borg user with read-only everywhere permissions
    borgbackup = {
      repos.paperless = {
        path = "/mnt/vault/backups/paperless";
        authorizedKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIb4sr8jfAagDEYJQg1Xa9WN1i+jQFzEnSvU/e1X4oed rutrum@rumtower"
        ];
      };
      jobs = {
        # backs up immich from rumnas -> rumtower
        local-rumtower = {
          paths = [
            # https://docs.immich.app/administration/backup-and-restore/#filesystem
            "/mnt/raid/immich/library"
            "/mnt/raid/immich/upload"
            "/mnt/raid/immich/profile"
            "/mnt/raid/immich/backups" # postgres dumps
            "/mnt/raid/homes/rutrum/media/home_video"
          ];
          compression = "auto,lzma";
          startAt = "daily";
          user = "root";
          doInit = false;
          repo = "ssh://rutrum@rumtower/mnt/barracuda/backup/immich";
          environment = {
            BORG_RSH = "ssh -i /home/rutrum/.ssh/id_ed25519";
            BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK = "yes";
          };
          encryption.mode = "none";
        };
      };
    };

    xserver = {
      enable = true;
      desktopManager.cinnamon.enable = true;
      displayManager.lightdm.enable = true;
    };
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

  # raid
  fileSystems = {
    "/mnt/raid" = {
      device = "/dev/md127";
      fsType = "btrfs";
    };
  };
  boot.swraid.enable = true;

  networking.firewall.enable = false; # remove this sometime? please uwu?

  services.displayManager.defaultSession = "cinnamon";

  users = {
    users.reolink = {
      isSystemUser = true;
      description = "Account for cameras to save recordings";
      group = "reolink";
      home = "/mnt/raid/reolink";
      shell = pkgs.bashInteractive;
    };
    groups.reolink = {};

    users.rutrum.extraGroups = ["jellyfin"];
  };

  environment.systemPackages = with pkgs; [
    ethtool # for tailscale optimization
    jellyfin-ffmpeg
    beets
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
