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

    # containized
    # consider using nixos modules for these
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

  networking.hostName = "rumtower";

  services = {
    xserver.enable = true;
    # maybe revisit when cursor bug is fixed
    #displayManager.gdm.enable = true;
    #desktopManager.gnome.enable = true;
    displayManager.sddm.enable = true;
    displayManager.sddm.wayland.enable = true;
    desktopManager.plasma6.enable = true;

    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        AllowUsers = ["rutrum"];
      };
    };

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

    tailscale = {
      useRoutingFeatures = "server";
      openFirewall = true;
      extraSetFlags = [
        "--advertise-exit-node" # allow clients to route traffic through nas
        "--exit-node-allow-lan-access"
        "--advertise-routes=192.168.50.100/32"
      ];
    };

    calibre-server = {
      enable = true;
      openFirewall = true;
      libraries = [
        "/mnt/barracuda/calibre"
      ];
      port = 8081;
    };
    calibre-web = {
      enable = true;
      openFirewall = true;
      listen.ip = "0.0.0.0";
    };

    prometheus = {
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
  };

  programs = {
    nix-ld.enable = true;
    xwayland.enable = true;

    wireshark = {
      enable = true;
      package = pkgs.wireshark; # UI application
    };
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  environment.systemPackages = with pkgs; [
    gnome-tweaks
    gnomeExtensions.tactile
    adwaita-icon-theme
    adwaita-fonts
    cifs-utils # mount samba share
  ];

  sops.secrets."smb_credentials".owner = "root";

  fileSystems = {
    #"/".device = "/dev/nvme0n1";
    "/mnt/barracuda" = {
      device = "/dev/sda";
      fsType = "ext4";
    };

    "/mnt/rumnas" = {
      device = "//nas.home/homes";
      fsType = "cifs";
      options = let
        # uid = config.users.users.rutrum.uid;
        uid = 1000;
        gid = config.users.groups.users.gid;
        creds_path = config.sops.secrets."smb_credentials".path;
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,user,users";
      in ["${automount_opts},uid=${toString uid},gid=${toString gid},credentials=${creds_path}" "nofail"];
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  networking.firewall.enable = false;
  networking.nftables.enable = true;

  system.stateVersion = "23.11";
}
