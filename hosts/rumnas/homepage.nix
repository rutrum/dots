{
  pkgs,
  config,
  lib,
  ...
}: {
  config = {
    services.homepage-dashboard = {
      enable = true;
      listenPort = 8181;
      allowedHosts = "localhost:8181,127.0.0.1:8181,rum.internal";
      openFirewall = false; # handled by caddy

      settings = {
        title = "Selfhosted";
        language = "en";
        theme = "dark";
      };

      services = [
        {
          Networking = [
            {
              Router = {
                icon = "asus";
                href = "http://192.168.50.1";
                description = "Home router";
              };
            }
            {
              "AdGuard Home" = {
                icon = "adguard-home";
                href = "http://adguard.rum.internal";
                description = "Local DNS and ad blocker";
              };
            }
          ];
        }
        {
          Monitoring = [
            {
              Grafana = {
                icon = "grafana";
                href = "http://grafana.rum.internal";
                description = "Data visualization";
              };
            }
            {
              Prometheus = {
                icon = "prometheus";
                href = "http://prometheus.rum.internal";
                description = "Metrics database";
              };
            }
            {
              Alertmanager = {
                icon = "alertmanager";
                href = "http://alertmanager.rum.internal";
                description = "Alert routing";
              };
            }
            {
              ntfy = {
                icon = "ntfy";
                href = "http://ntfy.rum.internal";
                description = "Notifications";
              };
            }
            {
              "Home Assistant" = {
                icon = "home-assistant";
                href = "http://hass.rum.internal";
                description = "Home automation";
              };
            }
          ];
        }
        {
          Misc = [
            {
              Doorbell = {
                icon = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/webp/reolink.webp";
                href = "http://192.168.50.100";
                description = "Front doorbell camera";
              };
            }
            {
              Octoprint = {
                icon = "octoprint";
                href = "http://192.168.50.2:5000";
                description = "3D printing";
              };
            }
            {
              "WeatherStar 4000+" = {
                icon = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/webp/weatherstar-4000-plus.webp";
                href = "http://weatherstar.rum.internal";
                description = "Retro 90s Weather Channel";
              };
            }
            {
              ConvertX = {
                icon = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/webp/convertx.webp";
                href = "http://convertx.rum.internal";
                description = "Online file converter";
              };
            }
          ];
        }
        {
          Downloads = [
            {
              Sonarr = {
                icon = "sonarr";
                href = "http://sonarr.rum.internal";
                description = "TV fetcher";
              };
            }
            {
              Radarr = {
                icon = "radarr";
                href = "http://radarr.rum.internal";
                description = "Movie fetcher";
              };
            }
            {
              Prowlarr = {
                icon = "prowlarr";
                href = "http://prowlarr.rum.internal";
                description = "Indexer";
              };
            }
            {
              Lidarr = {
                icon = "lidarr";
                href = "http://lidarr.rum.internal";
                description = "Music fetcher";
              };
            }
            {
              qBittorrent = {
                icon = "qbittorrent";
                href = "http://qbittorrent.rum.internal";
                description = "Torrent client";
              };
            }
            {
              ErsatzTV = {
                icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/ersatztv.svg";
                href = "http://ersatztv.rum.internal";
                description = "Stream TV channels";
              };
            }
          ];
        }
        {
          AI = [
            {
              LocalAI = {
                icon = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/webp/localai.webp";
                href = "http://local-ai.rum.internal";
                description = "Local LLM inference server";
              };
            }
            {
              "Hermes AI" = {
                icon = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/webp/hermes-agent.webp";
                href = "http://hermes.rum.internal";
                description = "Local AI agent";
              };
            }
          ];
        }
        {
          "Libraries & Life Admin" = [
            {
              Immich = {
                icon = "immich";
                href = "http://immich.rum.internal";
                description = "Photo gallery";
              };
            }
            {
              "Calibre Web" = {
                icon = "calibre-web";
                href = "http://calibre-web.rum.internal";
                description = "Book browser";
              };
            }
            {
              RomM = {
                icon = "romm";
                href = "http://romm.rum.internal";
                description = "Game manager";
              };
            }
            {
              Jellyfin = {
                icon = "jellyfin";
                href = "http://jellyfin.rum.internal";
                description = "Home media server";
              };
            }
            {
              Paperless = {
                icon = "paperless-ngx";
                href = "http://paperless.rum.internal";
                description = "Document organization";
              };
            }
            {
              NocoDB = {
                icon = "nocodb";
                href = "http://nocodb.rum.internal";
                description = "No code database";
              };
            }
            {
              Mealie = {
                icon = "mealie";
                href = "http://mealie.rum.internal";
                description = "Recipe manager";
              };
            }
            {
              FreshRSS = {
                icon = "freshrss";
                href = "http://freshrss.rum.internal";
                description = "RSS feed aggregator";
              };
            }
            {
              Firefly = {
                icon = "firefly-iii";
                href = "http://firefly.rum.internal";
                description = "Personal finance tracker";
              };
            }
            {
              LubeLogger = {
                icon = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/webp/lubelogger.webp";
                href = "http://lubelogger.rum.internal";
                description = "Vehicle maintenance tracker";
              };
            }
          ];
        }
        {
          "Cloud Hosted" = [
            {
              Nextcloud = {
                icon = "nextcloud";
                href = "https://cloud.rutrum.net";
                description = "Cloud suite";
              };
            }
            {
              "Paradisus Docs" = {
                icon = "https://paradisus.day/paradisus-logo-128x128.png";
                href = "https://paradisus.day";
                description = "Minecraft server documentation";
              };
            }
            {
              "stringcase.org" = {
                href = "https://stringcase.org";
                description = "Multiword identifiers";
              };
            }
            {
              "rutrum.net" = {
                href = "https://rutrum.net";
                description = "Personal website";
              };
            }
          ];
        }
        {
          "Managed Services" = [
            {
              Vultr = {
                icon = "vultr";
                href = "https://my.vultr.com";
                description = "Cloud provider";
              };
            }
            {
              Namecheap = {
                icon = "namecheap";
                href = "https://www.namecheap.com/myaccount/login";
                description = "DNS registrar";
              };
            }
            {
              Tailscale = {
                icon = "tailscale";
                href = "https://login.tailscale.com/login";
                description = "Mesh VPN service";
              };
            }
            {
              Proton = {
                icon = "proton";
                href = "https://account.proton.me/login";
                description = "Email provider";
              };
            }
            {
              BorgBase = {
                href = "https://borgbase.com/login";
                description = "Encrypted cloud backup";
              };
            }
            {
              SimpleLogin = {
                icon = "simplelogin";
                href = "https://app.simplelogin.io/auth/login";
                description = "Email aliasing";
              };
            }
            {
              Mullvad = {
                icon = "mullvad";
                href = "https://mullvad.net/en/account/login";
                description = "VPN service";
              };
            }
            {
              BitWarden = {
                icon = "bitwarden";
                href = "https://bitwarden.com/";
                description = "Password manager";
              };
            }
            {
              OpenRouter = {
                icon = "https://cdn.jsdelivr.net/gh/selfhst/icons@main/webp/openrouter.webp";
                href = "https://openrouter.ai/";
                description = "Multi-model LLM API";
              };
            }
          ];
        }
      ];
    };
  };
}
