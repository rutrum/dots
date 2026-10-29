---
name: add-application
description: |
    Add a new application to the self-hosted stack.
    Use when the user wants to install a new service and needs step-by-step
    guidance through the nixos module, container, sops, backup, proxy, and
    homepage patterns.
---

1. Identify the application and pick a deployment method. Check in order; the
   first two are a toss-up, so use whichever finds it:
   - nixpkgs (a native `services.<app>` module, or a package)
   - a flake input already in this repo (e.g. `llm-agents`)

2. Prefer an upstream flake + NixOS module from the project's own repo over
   packaging it yourself — many projects ship `nixosModules` now. Read its
   options before wiring anything: `nix eval --impure --raw --expr
   '(builtins.getFlake (toString ./.)).inputs.<name>.outPath'`, then read
   `nix/nixosModules.nix` in that store path.

3. Only if neither exists, choose as a judgement call about the project's
   design and reliability — there is no default:
   - a third-party community flake
   - a container (podman)
   - build it ourselves in `packages/`

4. Choose the host
   Most apps go on `rumnas`. Check if the app belongs on `rumtower` instead (e.g., Firefly III, pipances).

5. Create the module file
   - Small config -> extend `hosts/<host>/configuration.nix` inline.
   - Larger config -> create `hosts/<host>/<app-name>.nix`.
   - Multi-service -> use a broader name (e.g., `arr.nix`).
   - Wire it into `configuration.nix` via `imports = [ ./<app>.nix ];`.

6. Handle sops-nix secrets
   Three patterns, pick the one that fits:
   - Secret file: `sops.secrets."<app>/env".owner = "<user>";` then reference `config.sops.secrets."<app>/env".path`.
   - Env template: `sops.templates."<app>.env"` with `content` using `config.sops.placeholder."<app>/key"`.
   - Command string: `passCommand = "cat ${secrets."<app>/key".path}";`.
   Set `restartUnits` on secrets that need a service restart on change.

7. Set up backups
   Ask the user whether data directories should be backed up with borg. If yes, add paths to `hosts/rumnas/borg.nix` under `cloud-borgbase` or `local-rumtower`.

8. Make it accessible over HTTP
   Add `services.caddyProxy.services.<name>.port = <port>;` to the app file. The `caddy-proxy` module auto-generates both `http://<name>.rum.internal` and `https://<name>.internal.rutrum.net` virtual hosts. No manual DNS records needed.
   For apps with a DNS-rebinding/Origin guard, `caddyProxy` alone is not enough — use manual `caddy.virtualHosts` with `header_up Host` / `header_up Origin`.

9. Add to homepage dashboard
   Add a tile to `hosts/rumnas/homepage.nix` under the right category. Existing categories: `Networking`, `Monitoring`, `Misc`, `Downloads`, `AI`, `Libraries`, `Cloud Hosted`, `Managed Services`.

10. Handle additional concerns as needed
   - Podman network: `systemd.services = inputs.self.lib.mkPodmanNetwork config "<name>";` and `networks = ["<name>"]` on each container.
   - Database: `services.postgresql.ensureDatabases` / `ensureUsers`, or ship a bundled DB container.
   - User/group: Add system users or group memberships (`users.users.<app>.extraGroups`).
   - Firewall: `networking.firewall.allowedTCPPorts` for non-Caddy ports.
   - Version pinning: `nixpkgs.overlays` with `multiverse.lib.pinOverlay` if the nixpkgs version is wrong.
   - New flake input: Add to `flake.nix` inputs if the app comes from a flake.
   - Custom package: Build in `packages/<name>.nix` and reference via `flake.packages.${pkgs.system}.<name>`.
   - Service ordering: Use `after`/`requires`/`wantedBy` on systemd services when one container depends on another or on a native service.

11. Validate
    ```
    nixos-rebuild build --flake .#<host>
    ```
