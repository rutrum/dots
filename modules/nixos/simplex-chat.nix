{
  config,
  lib,
  pkgs,
  flake,
  ...
}: let
  cfg = config.services.simplex-chat;
  simplex-cli = flake.packages.${pkgs.system}.simplex-chat;
in {
  options.services.simplex-chat = {
    enable = lib.mkEnableOption "SimpleX Chat daemon (WebSocket server)";

    port = lib.mkOption {
      type = lib.types.port;
      default = 5225;
      description = "WebSocket port the daemon will listen on.";
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/simplex-chat";
      description = ''
        Directory for persistent data (SQLite databases).
        Must exist and be writable by the service user.
      '';
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "simplex-chat";
      description = "User that runs the simplex-chat daemon.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "simplex-chat";
      description = "Group for the simplex-chat daemon user.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open the firewall for the configured port.";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

    users.users.${cfg.user} = lib.mkIf (cfg.user == "simplex-chat") {
      isSystemUser = true;
      group = cfg.group;
      home = cfg.dataDir;
      createHome = true;
    };

    users.groups.${cfg.group} = lib.mkIf (cfg.group == "simplex-chat") {};

    systemd.services.simplex-chat = {
      description = "SimpleX Chat daemon";
      wantedBy = ["multi-user.target"];
      after = ["network-online.target"];
      wants = ["network-online.target"];

      serviceConfig = {
        Environment = "HOME=/var/lib/${cfg.user}";
        ExecStart = "${simplex-cli}/bin/simplex-chat -d ${cfg.dataDir}/simplex_v1 -p ${toString cfg.port}";
        WorkingDirectory = cfg.dataDir;
        User = cfg.user;
        Group = cfg.group;
        Restart = "on-failure";
        RestartSec = "5s";
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        ReadWritePaths =
          [cfg.dataDir]
          ++ lib.optionals (cfg.user != "simplex-chat") [
            "/var/lib/${cfg.user}"
          ];
        RestrictAddressFamilies = ["AF_INET" "AF_INET6" "AF_UNIX"];
      };
    };
  };
}
