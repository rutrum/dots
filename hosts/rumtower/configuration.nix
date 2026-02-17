{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.self.nixosModules.system
    ./hardware-configuration.nix
    ./syncthing.nix

    # containized
    # consider using nixos modules for these
    ./paperless.nix
    ./firefly.nix

    # monitoring
    ./prometheus.nix
    ./poweroff.nix

    inputs.self.nixosModules.gaming
    inputs.self.nixosModules.controller
    inputs.self.nixosModules.nvidia
    inputs.self.nixosModules.mouse
    inputs.self.nixosModules.qmk
    inputs.self.nixosModules.printing
    inputs.self.nixosModules.local-ai
    inputs.self.nixosModules.alloy
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
      device = "//rum.internal/homes";
      fsType = "cifs";
      options = let
        # uid = config.users.users.rutrum.uid;
        uid = 1000;
        gid = config.users.groups.users.gid;
        creds_path = config.sops.secrets."smb_credentials".path;
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=30s,x-systemd.mount-timeout=30s,soft,user,users";
      in ["${automount_opts},uid=${toString uid},gid=${toString gid},credentials=${creds_path}" "nofail"];
    };
  };

  networking.firewall.enable = false;
  networking.nftables.enable = true;

  # Signal rumnas to run Immich backup when rumtower boots
  systemd.services.signal-rumnas-backup = {
    description = "Signal rumnas to run Immich backup";
    after = ["network-online.target"];
    wants = ["network-online.target"];

    serviceConfig = {
      Type = "oneshot";
      User = "rutrum";
    };

    path = with pkgs; [openssh];

    script = ''
      ssh -o ConnectTimeout=10 rutrum@rumnas \
        'sudo ${pkgs.systemd}/bin/systemctl start backup-immich-cooldown.service' || true
    '';
  };

  systemd.timers.signal-rumnas-backup = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "2min";
      Unit = "signal-rumnas-backup.service";
    };
  };

  system.stateVersion = "23.11";
}
