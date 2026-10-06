{
  config,
  lib,
  ...
}: let
  cfg = config.services.caddyProxy;

  mkBackend = svc:
    if svc.host != null
    then "http://${svc.host}:${toString svc.port}"
    else "localhost:${toString svc.port}";

  mkProxyConfig = svc:
    if svc.phpSocket != null
    then ''
      root * ${svc.root}
      php_fastcgi unix/${svc.phpSocket}
      file_server
    ''
    else ''
      reverse_proxy ${mkBackend svc}
    '';

  # Every service always gets its plain-HTTP vhost under `domain`. When TLS is
  # enabled it additionally gets `https://<name>.<tls.domain>`, backed by the
  # wildcard certificate defined below (via Caddy's `useACMEHost`).
  mkVirtualHosts = name: svc: let
    proxyConfig = mkProxyConfig svc;
  in
    {
      "http://${name}.${cfg.domain}".extraConfig = proxyConfig;
    }
    // lib.optionalAttrs (cfg.tls.enable && svc.tls) {
      "${name}.${cfg.tls.domain}" = {
        useACMEHost = cfg.tls.domain;
        extraConfig = proxyConfig;
      };
    };

  allVirtualHosts = lib.mkMerge (lib.mapAttrsToList mkVirtualHosts cfg.services);
in {
  options.services.caddyProxy = {
    enable = lib.mkEnableOption "Caddy reverse proxy for homelab services";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "rum.internal";
      description = "Base domain for the plain-HTTP internal service vhosts";
    };

    tls = {
      enable = lib.mkEnableOption "wildcard-TLS internal vhosts via security.acme";

      domain = lib.mkOption {
        type = lib.types.str;
        default = "internal.rutrum.net";
        description = ''
          Domain used for the HTTPS vhosts: each service also answers on
          `https://<name>.<domain>`. A wildcard certificate for
          `*.<domain>` (plus `<domain>` itself) is issued with a DNS-01
          challenge, so the name never has to be publicly reachable.
        '';
      };

      dnsProvider = lib.mkOption {
        type = lib.types.str;
        default = "porkbun";
        description = "lego DNS provider used for the DNS-01 challenge";
      };

      environmentFile = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = ''
          Environment file holding the DNS provider credentials, in the format
          lego expects (e.g. `PORKBUN_API_KEY` / `PORKBUN_SECRET_API_KEY`).
        '';
      };

      email = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Contact email for the ACME account";
      };

      server = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "https://acme-staging-v02.api.letsencrypt.org/directory";
        description = ''
          ACME directory URL. `null` uses Let's Encrypt production; point this
          at the staging endpoint while bringing a new setup up.
        '';
      };
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
          tls = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = ''
              Also serve this service on `https://<name>.<tls.domain>`. Set to
              false for services that misbehave behind an HTTPS base URL.
            '';
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

    networking.firewall.allowedTCPPorts =
      [80]
      ++ lib.optional cfg.tls.enable 443;

    # Wildcard certificate shared by every HTTPS vhost. The Caddy module adds
    # the matching `tls` directives and reloads Caddy on renewal.
    security.acme = lib.mkIf cfg.tls.enable {
      acceptTerms = true;
      defaults.email = cfg.tls.email;
      certs.${cfg.tls.domain} =
        {
          domain = "*.${cfg.tls.domain}";
          extraDomainNames = [cfg.tls.domain];
          dnsProvider = cfg.tls.dnsProvider;
          environmentFile = cfg.tls.environmentFile;
          group = "caddy";
        }
        // lib.optionalAttrs (cfg.tls.server != null) {
          server = cfg.tls.server;
        };
    };
  };
}
