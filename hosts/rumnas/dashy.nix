{
  pkgs,
  config,
  lib,
  ...
}: let
  rumnas = "http://rumnas.lynx-chromatic.ts.net";
  rumnas_ip = "http://192.168.50.3"; # shouldn't be necessary
  rumtower = "http://rumtower.lynx-chromatic.ts.net";
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
            url = "${rumnas_ip}:3001"; # tailscale address doesn't work for this one?
          }
          {
            title = "Jellyfin";
            description = "Home media server";
            icon = "hl-jellyfin";
            url = "${rumnas}:8096";
          }
          {
            title = "ErsatzTV";
            description = "Stream TV channels";
            icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/ersatztv.svg";
            url = "${rumnas}:8409";
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
            url = "${rumnas}:8081";
          }
          {
            title = "Home Assistant";
            description = "Home automation";
            icon = "hl-home-assistant";
            url = "${rumnas}:8082";
          }
          {
            title = "Paperless";
            description = "Document organization";
            icon = "hl-paperless";
            url = "${rumtower}:8000";
          }
          {
            title = "Firefly";
            description = "Personal finance tracker";
            icon = "hl-firefly";
            url = "${rumtower}:8080";
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
            url = "${rumnas}:3000";
          }
          {
            title = "Open WebUI";
            description = "LLM chat interface";
            icon = "hl-open-webui";
            url = "${rumnas}:8080";
          }
          {
            title = "Mealie";
            description = "Recipe manager";
            icon = "hl-mealie";
            url = "${rumnas}:9000";
          }
          {
            title = "FreshRSS";
            description = "RSS feed aggregator";
            icon = "hl-freshrss";
            url = "${rumnas}:8085";
          }
          {
            title = "Calibre Web";
            description = "Book browser";
            icon = "hl-calibre-web";
            url = "${rumtower}:8083";
          }
          {
            title = "ntfy";
            description = "Notifications";
            icon = "hl-ntfy";
            url = "${rumnas}:8888";
          }
          {
            title = "Immich";
            description = "Photo gallery";
            icon = "hl-immich";
            url = "${rumnas}:2283";
          }
          {
            title = "Local AI (rumtower)";
            description = "AI model management";
            icon = "sh-localai";
            url = "${rumtower}:8089";
          }
          {
            title = "Local AI (rumnas)";
            description = "AI model management";
            icon = "sh-localai";
            url = "${rumnas}:8089";
          }
          {
            title = "Karakeep";
            description = "Bookmarks";
            icon = "hl-karakeep";
            url = "${rumnas}:8090";
          }
          {
            title = "RomM";
            description = "Game manager";
            icon = "hl-romm";
            url = "${rumnas}:8087";
          }
          {
            title = "qBittorrent";
            description = "Torrent client";
            icon = "hl-qbittorrent";
            url = "${rumnas}:9009";
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
  config.virtualisation.oci-containers = {
    containers = {
      dashy = {
        image = "lissy93/dashy";
        ports = ["80:8080"];
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
