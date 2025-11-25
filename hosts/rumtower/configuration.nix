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
    ./syncthing.nix
    ./calibre.nix

    # containized
    ./paperless.nix
    ./firefly.nix

    ../modules/gnome.nix
    ../modules/gaming.nix

    ../modules/printing.nix

    ../modules/services/llm.nix

    ../../modules/nixos/nvidia.nix
    ../../modules/nixos/mouse.nix
    ../../modules/nixos/qmk.nix
  ];

  # options for local modules
  me = {
    llm.enable-open-webui = false;
  };

  programs.nix-ld.enable = true;

  networking.hostName = "rumtower";

  services = {
    postgresql = {
      enable = true;
      ensureDatabases = ["health"];
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

  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
    applications.apps = [
      {
        name = "Blasphemous";
        detached = [
          "setsid steam steam://rungameid/774361"
        ];
      }
      {
        name = "Desktop";
        image-path = "desktop.png";
      }
      {
        name = "Low Res Desktop";
        image-path = "desktop.png";
        prep-cmd = [
          {
            do = "xrandr --output HDMI-1 --mode 1920x1080";
            undo = "xrandr --output HDMI-1 --mode 1920x1200";
          }
        ];
      }
      {
        name = "Steam Big Picture";
        detached = [
          "setsid steam steam://open/bigpicture"
        ];
        image-path = "steam.png";
      }
    ];
  };
  networking.firewall = {
    allowedTCPPorts = [47984 47989 47990 48010];
    allowedUDPPortRanges = [
      {
        from = 47998;
        to = 48000;
      }
      #{ from = 8000; to = 8010; }
    ];
  };

  services.tailscale = {
    useRoutingFeatures = "server";
    openFirewall = true;
    extraSetFlags = [
      "--advertise-exit-node" # allow clients to route traffic through nas
      "--exit-node-allow-lan-access"
      "--advertise-routes=192.168.50.100/32"
    ];
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

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark; # UI application
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  networking.firewall.enable = false;
  networking.nftables.enable = true;

  system.stateVersion = "23.11";
}
