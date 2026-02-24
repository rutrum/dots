{
  config,
  lib,
  ...
}: let
  cfg = config.services.caddyProxy;

  mkVirtualHost = name: svc: let
    backend =
      if svc.host != null
      then "http://${svc.host}:${toString svc.port}"
      else "localhost:${toString svc.port}";
    proxyConfig =
      if svc.phpSocket != null
      then ''
        root * ${svc.root}
        php_fastcgi unix/${svc.phpSocket}
        file_server
      ''
      else ''
        reverse_proxy ${backend}
      '';
  in {
    name = "http://${name}.${cfg.domain}";
    value.extraConfig = proxyConfig;
  };

  allVirtualHosts = lib.listToAttrs (lib.mapAttrsToList mkVirtualHost cfg.services);
in {
  options.services.caddyProxy = {
    enable = lib.mkEnableOption "Caddy reverse proxy for homelab services";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "rum.internal";
      description = "Base domain for all services";
    };

    services = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          port = lib.mkOption {
            type = lib.types.port;
            description = "Port the service listens on";
          };
          host = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Hostname or IP of the backend (null for localhost)";
          };
          phpSocket = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "PHP-FPM socket path for PHP applications";
          };
          root = lib.mkOption {
            type = lib.types.nullOr lib.types.path;
            default = null;
            description = "Root path for PHP-FPM services";
          };
        };
      });
      default = {};
      description = "Services to proxy via Caddy";
    };
  };

  config = lib.mkIf cfg.enable {
    services.caddy = {
      enable = true;
      virtualHosts = allVirtualHosts;
    };

    networking.firewall.allowedTCPPorts = [80];
  };
}
