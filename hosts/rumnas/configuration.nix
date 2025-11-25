{
  pkgs,
  lib,
  inputs,
  config,
  ...
}: {
  imports = [
    ../system.nix
    ./hardware-configuration.nix
    ./samba.nix
    ./cache.nix
    ./openrgb.nix
    ./immich.nix
    ./adguardhome.nix

    # containerized
    ./nocodb.nix
    ./freshrss.nix
    ./dashy.nix
    ./home-assistant.nix

    #../modules/gnome.nix
    ../modules/gaming.nix

    # TODO: this is failing due to nvidia issues
    # ../modules/services/ersatztv.nix

    #../modules/services/rustdesk.nix

    ../../modules/nixos/nvidia.nix

    # bare metal
    ../modules/services/llm.nix

    # container services
    # ../modules/services/linkwarden.nix
  ];

  networking.hostName = "rumnas";

  services = {
    qbittorrent = {
      enable = true;
      openFirewall = true;
      webuiPort = 9009;
    };

    grafana = {
      enable = true;
      settings = {
        server = {
          http_addr = "0.0.0.0";
          http_port = 3000;
          domain = "rumtower.lynx-chromatic.ts.net";
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
      # package = inputs.nixpkgs-unstable.x86_64-linux.pkgs.jellyfin;
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
    # allow x forwarding
    #programs.ssh.forwardX11 = true;

    # backups?
    borgbackup.repos.paperless = {
      path = "/mnt/vault/backups/paperless";
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIb4sr8jfAagDEYJQg1Xa9WN1i+jQFzEnSvU/e1X4oed rutrum@rumtower"
      ];
    };
    xserver = {
      enable = true;
      desktopManager = {
        #gnome.enable = true;
        cinnamon.enable = true;
      };
      displayManager.lightdm = {
        enable = true;
      };
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

  #services.xserver.desktopManager.lxqt.enable = true;
  #services.xserver.desktopManager.cinnamon.enable = true;
  #services.xserver.displayManager.lightdm.enable = true;
  #services.xserver = {
  #  enable = true;
  #  displayManager.gdm.enable = true;
  #  desktopManager.gnome.enable = true;
  #  #desktopManager.cinnamon.enable = true;
  #};

  services.displayManager.defaultSession = "cinnamon";
  #services.xserver.displayManager.lightdm.enable = true;
  #services.xserver.desktopManager.cinnamon.enable = true;

  #services.cinnamon.apps.enable = true;

  users = {
    users.reolink = {
      isSystemUser = true;
      description = "Account for cameras to save recordings";
      group = "reolink";
      home = "/mnt/raid/reolink";
      shell = pkgs.bashInteractive;
    };
    # normal users are part of "user" group by default
    groups.reolink = {};
    users.rutrum.extraGroups = ["jellyfin"];
  };

  # Enable automatic login for the user.
  #services.getty.autologinUser = "rutrum";

  environment.systemPackages = with pkgs; [
    ethtool # for tailscale optimization
    jellyfin-ffmpeg
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
