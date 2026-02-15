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
    ./paperless.nix

    # monitoring
    ./prometheus.nix
    ./loki.nix

    # backup
    ./borg.nix

    inputs.self.nixosModules.gaming
    inputs.self.nixosModules.controller
    inputs.self.nixosModules.nvidia
    inputs.self.nixosModules.local-ai
    inputs.self.nixosModules.caddy-proxy
    inputs.self.nixosModules.alloy
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

    openssh.enable = true;

    caddyProxy = {
      enable = true;
      # domain defaults to "rum.home"
      services = {
        # rumnas services defined in their own files (immich.nix, etc.)
        # services defined here don't have dedicated files on rumnas
        openwebui.port = 8080;
        grafana.port = 3000;
        prometheus.port = 9090;
        alertmanager.port = 9093;
        mealie.port = 9000;
        ntfy.port = 8888;
        jellyfin.port = 8096;
        ersatztv.port = 8409;
        # rumtower services (proxied remotely)
        paperless.port = 8000;
        calibre = {
          port = 8081;
          host = "rumtower";
        };
        calibre-web = {
          port = 8083;
          host = "rumtower";
        };
      };
    };

    # Make rum.internal (bare domain) go to Dashy
    caddy.virtualHosts."http://rum.internal".extraConfig = ''
      reverse_proxy localhost:8180
    '';

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

  # Allow rutrum to trigger the backup service via SSH from rumtower
  security.sudo.extraRules = [
    {
      users = ["rutrum"];
      commands = [
        {
          command = "${pkgs.systemd}/bin/systemctl start backup-immich-cooldown.service";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];

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

    users.rutrum.extraGroups = [
      "jellyfin" # media directory
      "paperless" # consume directory
    ];
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
