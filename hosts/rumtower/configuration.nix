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

    ../modules/cosmic.nix
    ../modules/gnome.nix
    ../modules/gaming.nix

    ../modules/printing.nix

    ../modules/docker.nix
    ../modules/services/llm.nix
    ../modules/services/jellyfin.nix
    ../modules/services/immich.nix
    ../modules/services/paperless.nix
    ../modules/services/firefly.nix

    ../modules/hardware/nvidia.nix
    # ../modules/hardware/8bitdo.nix
    ../modules/hardware/mouse.nix
    ../modules/hardware/qmk.nix
  ];

  # options for local modules
  me = {
    llm.enable-open-webui = false;
  };

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

  services.tailscale = {
    useRoutingFeatures = "server";
    openFirewall = true;
    extraUpFlags = [
      "--advertise-exit-node" # allow clients to route traffic through nas
      "--exit-node-allow-lan-access"
      "--advertise-routes=192.168.50.0/24"
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
