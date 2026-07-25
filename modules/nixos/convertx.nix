{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.convertx;
in {
  options.services.convertx = {
    enable = lib.mkEnableOption "ConvertX self-hosted online file converter";

    port = lib.mkOption {
      type = lib.types.port;
      default = 3000;
      description = "TCP port the server will listen on.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open the firewall for the configured port.";
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/convertx";
      description = ''
        Directory for persistent data (uploads, output, database).
        Must exist and be writable by the convertx system user.
      '';
    };

    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = ''
        Extra environment variables passed to ConvertX.
        See https://github.com/C4illin/ConvertX for supported vars:
        ACCOUNT_REGISTRATION, HTTP_ALLOWED, ALLOW_UNAUTHENTICATED,
        AUTO_DELETE_EVERY_N_HOURS, WEBROOT, HIDE_HISTORY, TZ, etc.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

    users.users.convertx = {
      isSystemUser = true;
      group = "convertx";
      home = cfg.dataDir;
      createHome = true;
    };

    users.groups.convertx = {};

    systemd.services.convertx = {
      description = "ConvertX – Self-hosted online file converter";
      wantedBy = ["multi-user.target"];
      after = ["network-online.target"];
      wants = ["network-online.target"];

      environment =
        {
          PORT = toString cfg.port;
          NODE_ENV = "production";
        }
        // cfg.environment;

      serviceConfig = {
        ExecStart = "${pkgs.convertx}/bin/convertx";
        WorkingDirectory = cfg.dataDir;
        User = "convertx";
        Group = "convertx";
        Restart = "on-failure";
        RestartSec = "5s";
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        RestrictAddressFamilies = ["AF_INET" "AF_INET6" "AF_UNIX"];
      };
    };
  };
}
