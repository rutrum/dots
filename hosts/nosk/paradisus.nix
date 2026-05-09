{
  pkgs,
  config,
  ...
}: {
  # Webhook hooks for paradisus.day sites.
  # These merge with the existing webhook service defined in static-sites.nix.
  #
  # Private repos require an SSH deploy key at /var/lib/webhook/.ssh/id_ed25519
  # (placed manually — see post-deploy setup notes).
  # The same key can be added as a deploy key to both admin-docs and
  # minecraft-stats on GitHub.
  services.webhook.hooks = {
    build-paradisus-day = {
      command-working-directory = "/srv/git/admin-docs";
      include-command-output-in-response = true;
      execute-command = let
        script = pkgs.writeTextFile {
          name = "build-docs.sh";
          executable = true;
          text = ''
            #!/bin/sh
            set -e

            # Use webhook user's deploy key for private repo access
            export GIT_SSH_COMMAND="${pkgs.openssh}/bin/ssh -i /var/lib/webhook/.ssh/id_ed25519 -o StrictHostKeyChecking=accept-new"

            # Set cache dir so nix can write to it
            export XDG_CACHE_HOME=/tmp

            # Pull latest changes
            ${pkgs.git}/bin/git pull

            # Build with nix and copy to serve directory (rsync deletes stale files)
            ${pkgs.nix}/bin/nix build --no-link --print-out-paths | xargs -I{} ${pkgs.rsync}/bin/rsync -a --delete {}/ /srv/http/admin-docs/

            echo "Successfully built admin-docs"
          '';
        };
      in "${script}";
    };
  };

  # Caddy virtual host for paradisus.day.
  # Merges with extraConfig defined in static-sites.nix and nextcloud.nix.
  #
  # Note: webhook URLs have changed from paradisus.day:9000/hooks/<name>
  # to paradisus.day/hooks/<name> — update any GitHub webhook configurations.
  services.caddy.extraConfig = ''
    paradisus.day {
      # Webhook handler — proxies to the shared webhook service
      handle /hooks/* {
        reverse_proxy localhost:9000
      }

      # Minecraft stats (season 1)
      redir /stats /stats/
      handle_path /stats/* {
        root * /srv/http/minecraft-stats
        file_server
      }

      # Minecraft stats (season 2)
      redir /s2-stats /s2-stats/
      handle_path /s2-stats/* {
        root * /srv/http/s2-stats
        file_server
      }

      # Public file distribution
      redir /files /files/
      handle_path /files/* {
        root * /srv/http/files
        file_server browse
      }

      # Admin docs at root (catch-all, must come last)
      handle {
        root * /srv/http/admin-docs
        file_server
      }

      encode gzip
    }
  '';

  # Bore tunnel server — clients connect here to create reverse tunnels
  sops.secrets.bore = {};

  systemd.services.bore-server = {
    description = "bore tunnel server";
    wantedBy = ["multi-user.target"];
    after = ["network.target"];
    script = "${pkgs.bore-cli}/bin/bore server --secret $(cat ${config.sops.secrets.bore.path})";
  };

  networking.firewall.allowedTCPPorts = [
    7835 # bore control port
  ];

  environment.systemPackages = [pkgs.bore-cli];

  # Give webhook a real home directory so SSH keys and git operations work
  # when running as the webhook user. The NixOS webhook module defaults to
  # /var/empty which is read-only.
  users.users.webhook.home = "/var/lib/webhook";

  # Directories for paradisus.day content.
  # webhook owns git repos; caddy needs read access to http dirs.
  systemd.tmpfiles.rules = [
    "d /srv/git/admin-docs      0755 webhook webhook -"
    "d /srv/http/admin-docs     0775 webhook caddy   -"
    "d /srv/http/minecraft-stats 0775 webhook caddy  -"
    "d /srv/http/s2-stats       0775 webhook caddy   -"
    "d /srv/http/files          0775 webhook caddy   -"
  ];
}
