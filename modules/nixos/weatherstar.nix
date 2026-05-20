{
  config,
  lib,
  pkgs,
  flake,
  ...
}: let
  cfg = config.services.weatherstar;
  pkg = flake.packages.${pkgs.system}.ws4kp;
in {
  options.services.weatherstar = {
    enable = lib.mkEnableOption "WeatherStar 4000+ retro weather channel";

    port = lib.mkOption {
      type = lib.types.port;
      default = 8086;
      description = "Port the server will listen on.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open the firewall for the configured port.";
    };

    # WSQS_ env vars set the default query-string config (location, enabled screens, etc.)
    # See: https://github.com/netbymatt/ws4kp#default-query-string-parameters-environment-variables
    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Path to a file of environment variables. Variables prefixed with
        WSQS_ become default query-string parameters, e.g.:
          WSQS_latLonQuery=Chicago O'Hare International Airport
          WSQS_travel_checkbox=false
      '';
    };

    defaultLocation = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "Indianapolis International Airport Indianapolis IN USA";
      description = "Default location query string (sets WSQS_latLonQuery).";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];

    systemd.services.weatherstar = {
      description = "WeatherStar 4000+";
      wantedBy = ["multi-user.target"];
      after = ["network-online.target"];
      wants = ["network-online.target"];

      environment =
        {
          WS4KP_PORT = toString cfg.port;
        }
        // lib.optionalAttrs (cfg.defaultLocation != null) {
          WSQS_latLonQuery = cfg.defaultLocation;
        };

      serviceConfig = {
        ExecStart = "${pkg}/bin/ws4kp";
        WorkingDirectory = "${pkg}/lib/ws4kp";
        Restart = "on-failure";
        RestartSec = "5s";
        DynamicUser = true;
        EnvironmentFile = lib.mkIf (cfg.environmentFile != null) cfg.environmentFile;
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        RestrictAddressFamilies = ["AF_INET" "AF_INET6"];
      };
    };
  };
}
