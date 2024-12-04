{ pkgs, config, lib, ... }: let
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
            url = "http://192.168.50.3:3001"; # tailscale address doesn't work for this one?
          }
          {
            title = "Jellyfin";
            description = "Home media server";
            icon = "http://rumtower.lynx-chromatic.ts.net:8096/web/bc8d51405ec040305a87.ico";
            url = "http://rumnas.lynx-chromatic.ts.net:8096";
          }
          {
            title = "TabbyML";
            description = "AI code assistant";
            icon = "https://raw.githubusercontent.com/TabbyML/tabby/main/website/static/img/favicon.ico";
            url = "http://rumnas.lynx-chromatic.ts.net:11029";
          }
          {
            title = "Octoprint";
            description = "3D printing";
            icon = "hl-octoprint";
            url = "http://192.168.50.2:5000";
          }
          {
            title = "NocoDB";
            description = "No code database";
            icon = "http://rumnas.lynx-chromatic.ts.net:8081/dashboard/_nuxt/256x256.DJId9Ub8.png";
            url = "http://rumnas.lynx-chromatic.ts.net:8081";
          }
          {
            title = "Home Assistant";
            description = "Home automation";
            icon = "hl-home-assistant";
            url = "http://rumnas.lynx-chromatic.ts.net:8082";
          }
          {
            title = "Paperless";
            description = "Document organization";
            icon = "hl-paperless";
            url = "http://rumtower.lynx-chromatic.ts.net:8000";
          }
          {
            title = "Firefly";
            description = "Personal finance tracker";
            icon = "hl-firefly";
            url = "http://rumtower.lynx-chromatic.ts.net:8080";
          }
          {
            title = "Router";
            description = "Home router";
            icon = "si-asus";
            url = "http://192.168.50.1";
          }
          {
            title = "Tube Archivist";
            description = "Local YouTube video library";
            icon = "hl-tube-archivist";
            url = "http://rumnas.lynx-chromatic.ts.net:8090";
          }
          {
            title = "Grafana";
            description = "Data visualization";
            icon = "hl-grafana";
            url = "http://rumnas.lynx-chromatic.ts.net:3000";
          }
          {
            title = "Open WebUI";
            description = "LLM chat interface";
            icon = "hl-open-webui";
            url = "http://rumnas.lynx-chromatic.ts.net:8080";
          }
          {
            title = "Mealie";
            description = "Recipe manager";
            icon = "hl-mealie";
            url = "http://rumnas.lynx-chromatic.ts.net:9000";
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
            target = "newtab";
          }
          {
            title = "Paradisus Docs";
            description = "Minecraft server documentation";
            icon = "hl-minecraft";
            url = "https://paradisus.day";
          }
          {
            title = "Lemmy";
            description = "Link aggregation platform";
            icon = "hl-lemmy";
            url = "https://lm.paradisus.day";
          }
          {
            title = "stringcase.org";
            icon = "hl-spring_creators";
            url = "https://stringcase.org";
          }
          {
            title = "rutrum.net";
            description = "Dave's personal site";
            url = "https://rutrum.net";
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
            icon = "si-vultr";
          }
          {
            title = "Namecheap";
            description = "DNS registrar";
            url = "https://www.namecheap.com/myaccount/login";
          }
          {
            title = "Tailscale";
            description = "Mesh VPN service";
            url = "https://login.tailscale.com/login";
            icon = "si-tailscale";
          }
          {
            title = "Proton";
            description = "Email provider";
            url = "https://account.proton.me/login";
            icon = "si-proton";
          }
          {
            title = "BorgBase";
            description = "Encrypted cloud backup";
            url = "https://borgbase.com/login";
            icon = "si-borgbase";
          }
          {
            title = "SimpleLogin";
            description = "Email aliasing";
            url = "https://app.simplelogin.io/auth/login";
            icon = "si-simplelogin";
          }
          {
            title = "Mullvad";
            description = "VPN service";
            url = "https://mullvad.net/en/account/login";
          }
        ];
      }
    ];
  };
in {
  options.dashy.port = lib.mkOption {
    type = lib.types.int;
    description = "The port to bound Dashy to.";
  };

  config.virtualisation.oci-containers = {
    containers = {
      dashy = {
        image = "lissy93/dashy";
        ports = [ "${toString config.dashy.port}:8080" ];
        autoStart = true;
        volumes = [
          #"/root/dashy_config:/app/user-data"
          "${dashy_conf}:/app/user-data/conf.yml"
        ];
        environment = {
          #NODE_ENV = "production";
        };
      };
    };
  };
}
