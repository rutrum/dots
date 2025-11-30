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

    ../../modules/nixos/gaming.nix

    ../../modules/nixos/controller.nix
    ../../modules/nixos/nvidia.nix
    ../../modules/nixos/mouse.nix
    ../../modules/nixos/qmk.nix
    ../../modules/nixos/printing.nix
    ../../modules/nixos/local-ai.nix
  ];

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = ["rutrum"];
    };
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
    gnome-tweaks
    gnomeExtensions.tactile
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
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  networking.firewall.enable = false;
  networking.nftables.enable = true;

  system.stateVersion = "23.11";
}
