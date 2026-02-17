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

              # Pull latest changes
              ${pkgs.git}/bin/git pull

              # Build with Zola (rutrum.net uses Zola)
              ${pkgs.zola}/bin/zola build --output-dir /srv/http/rutrum-net/

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
      # rutrum.net - Hugo static site
      rutrum.net {
        root * /srv/http/rutrum-net
        file_server
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
