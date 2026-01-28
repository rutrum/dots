{
  pkgs,
  config,
  lib,
  ...
}: let
  rumpi_ip = "http://192.168.50.2";

  dashy_conf = pkgs.writers.writeYAML "conf.yml" {
    appConfig = {
      language = "en";
      layout = "auto";
      iconSize = "large";
      theme = "nord";
      auth.enableGuestAccess = true;
    };
    pageInfo = {
      title = "Selfhosted";
      navLinks = [];
    };
    sections = [
      {
        name = "Local Network";
        items = [
          {
            title = "AdGuard Home";
            description = "Local DNS and ad blocker";
            icon = "hl-adguard-home";
            url = "http://adguard.rum.internal";
          }
          {
            title = "Jellyfin";
            description = "Home media server";
            icon = "hl-jellyfin";
            url = "http://jellyfin.rum.internal";
          }
          {
            title = "ErsatzTV";
            description = "Stream TV channels";
            icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/ersatztv.svg";
            url = "http://ersatztv.rum.internal";
          }
          {
            title = "Octoprint";
            description = "3D printing";
            icon = "hl-octoprint";
            url = "${rumpi_ip}:5000";
          }
          {
            title = "NocoDB";
            description = "No code database";
            icon = "https://raw.githubusercontent.com/nocodb/nocodb/refs/heads/develop/packages/nc-gui/assets/img/icons/64x64.png";
            url = "http://nocodb.rum.internal";
          }
          {
            title = "Home Assistant";
            description = "Home automation";
            icon = "hl-home-assistant";
            url = "http://hass.rum.internal";
          }
          {
            title = "Paperless";
            description = "Document organization";
            icon = "hl-paperless";
            url = "http://paperless.rum.internal";
          }
          {
            title = "Firefly";
            description = "Personal finance tracker";
            icon = "hl-firefly";
            url = "http://firefly.rum.internal";
          }
          {
            title = "Router";
            description = "Home router";
            icon = "si-asus";
            url = "http://192.168.50.1";
          }
          {
            title = "Grafana";
            description = "Data visualization";
            icon = "hl-grafana";
            url = "http://grafana.rum.internal";
          }
          {
            title = "Prometheus";
            description = "Metrics database";
            icon = "hl-prometheus";
            url = "http://prometheus.rum.internal";
          }
          {
            title = "Open WebUI";
            description = "LLM chat interface";
            icon = "hl-open-webui";
            url = "http://openwebui.rum.internal";
          }
          {
            title = "Mealie";
            description = "Recipe manager";
            icon = "hl-mealie";
            url = "http://mealie.rum.internal";
          }
          {
            title = "FreshRSS";
            description = "RSS feed aggregator";
            icon = "hl-freshrss";
            url = "http://freshrss.rum.internal";
          }
          {
            title = "Calibre Web";
            description = "Book browser";
            icon = "hl-calibre-web";
            url = "http://calibre-web.rum.internal";
          }
          {
            title = "ntfy";
            description = "Notifications";
            icon = "hl-ntfy";
            url = "http://ntfy.rum.internal";
          }
          {
            title = "Immich";
            description = "Photo gallery";
            icon = "hl-immich";
            url = "http://immich.rum.internal";
          }
          {
            title = "RomM";
            description = "Game manager";
            icon = "hl-romm";
            url = "http://romm.rum.internal";
          }
          {
            title = "qBittorrent";
            description = "Torrent client";
            icon = "hl-qbittorrent";
            url = "http://qbittorrent.rum.internal";
          }
        ];
      }
      {
        name = "Cloud Hosted";
        items = [
          {
            title = "Nextcloud";
            description = "Cloud suite";
            icon = "hl-nextcloud";
            url = "https://cloud.rutrum.net";
          }
          {
            title = "Paradisus Docs";
            description = "Minecraft server documentation";
            icon = "hl-minecraft";
            url = "https://paradisus.day";
          }
          {
            title = "stringcase.org";
            description = "Multiword identifiers";
            url = "https://stringcase.org";
            icon = "favicon";
          }
          {
            title = "rutrum.net";
            description = "Personal website";
            url = "https://rutrum.net";
            icon = "favicon";
          }
        ];
      }
      {
        name = "Managed Services";
        items = [
          {
            title = "Vultr";
            description = "Cloud provider";
            url = "https://my.vultr.com";
            icon = "hl-vultr";
          }
          {
            title = "Namecheap";
            description = "DNS registrar";
            url = "https://www.namecheap.com/myaccount/login";
            icon = "favicon";
          }
          {
            title = "Tailscale";
            description = "Mesh VPN service";
            url = "https://login.tailscale.com/login";
            icon = "favicon";
          }
          {
            title = "Proton";
            description = "Email provider";
            url = "https://account.proton.me/login";
            icon = "favicon";
          }
          {
            title = "BorgBase";
            description = "Encrypted cloud backup";
            url = "https://borgbase.com/login";
            icon = "favicon";
          }
          {
            title = "SimpleLogin";
            description = "Email aliasing";
            url = "https://app.simplelogin.io/auth/login";
            icon = "favicon";
          }
          {
            title = "Mullvad";
            description = "VPN service";
            icon = "favicon";
            url = "https://mullvad.net/en/account/login";
          }
          {
            title = "BitWarden";
            description = "Password manager";
            icon = "hl-bitwarden";
            url = "https://bitwarden.com/";
          }
        ];
      }
      {
        name = "Cameras";
        items = [
          {
            title = "Doorbell";
            description = "Front doorbell camera";
            url = "http://192.168.50.100";
            icon = "favicon";
          }
        ];
      }
    ];
  };
in {
  config.services.caddyProxy.services.dashy.port = 8180;

  # Make rum.home (bare domain) go to Dashy
  config.services.caddy.virtualHosts."http://rum.internal".extraConfig = ''
    reverse_proxy localhost:8180
  '';

  config.virtualisation.oci-containers = {
    containers = {
      dashy = {
        image = "lissy93/dashy";
        ports = ["8180:8080"];
        autoStart = true;
        volumes = [
          "${dashy_conf}:/app/user-data/conf.yml"
        ];
        environment = {
          #NODE_ENV = "production";
        };
      };
    };
  };
}
