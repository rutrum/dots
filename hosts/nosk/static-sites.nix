{pkgs, ...}: {
  # Webhook service for auto-building static sites
  services.webhook = {
    enable = true;
    port = 9000;
    openFirewall = false; # We manage firewall in configuration.nix

    hooks = {
      build-rutrum-net = {
        command-working-directory = "/srv/git/rutrum-net";
        include-command-output-in-response = true;
        execute-command = let
          script = pkgs.writeTextFile {
            name = "build-rutrum-net.sh";
            executable = true;
            text = ''
              #!/bin/sh
              set -e

              # Set cache dir so nix can write to it
              export XDG_CACHE_HOME=/tmp

              # Pull latest changes
              ${pkgs.git}/bin/git pull

              # Build with nix and copy to serve directory
              ${pkgs.nix}/bin/nix build --no-link --print-out-paths | xargs -I{} cp -rT {} /srv/http/rutrum-net/

              echo "Successfully built rutrum.net"
            '';
          };
        in "${script}";
      };

      build-stringcase-org = {
        command-working-directory = "/srv/git/stringcase-org";
        include-command-output-in-response = true;
        execute-command = let
          script = pkgs.writeTextFile {
            name = "build-stringcase-org.sh";
            executable = true;
            text = ''
              #!/bin/sh
              set -e

              # Pull latest changes
              ${pkgs.git}/bin/git pull

              # Update git submodules (for Hugo themes)
              ${pkgs.git}/bin/git submodule update --init --recursive

              # Build with Hugo (stringcase.org uses Hugo)
              ${pkgs.hugo}/bin/hugo --destination /srv/http/stringcase-org/

              echo "Successfully built stringcase.org"
            '';
          };
        in "${script}";
      };
    };
  };

  # Caddy web server for serving static sites
  services.caddy = {
    enable = true;
    extraConfig = ''
      # rutrum.net - Zola static site
      rutrum.net {
        handle /hooks/* {
          reverse_proxy localhost:9000
        }
        handle {
          root * /srv/http/rutrum-net
          file_server
        }
        encode gzip
      }

      # stringcase.org - Zola static site
      stringcase.org {
        root * /srv/http/stringcase-org
        file_server
        encode gzip
      }
    '';
  };

  # Create directories with proper permissions
  systemd.tmpfiles.rules = [
    "d /srv/git 0755 webhook webhook -"
    "d /srv/http 0775 webhook caddy -"
    "d /srv/git/rutrum-net 0755 webhook webhook -"
    "d /srv/git/stringcase-org 0755 webhook webhook -"
    "d /srv/http/rutrum-net 0775 webhook caddy -"
    "d /srv/http/stringcase-org 0775 webhook caddy -"
  ];
}
