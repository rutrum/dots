# AGENTS.md

## Architecture Overview

### Structure
- **Framework:** [Blueprint](https://github.com/numtide/blueprint) for flake organization
- **NixOS 25.11** (release branch with unstable fallback)
- **Home Manager** for user configuration
- **SOPS-nix** for encrypted secrets management using age encryption
- **Flakes** enabled for reproducible builds

### Directory Organization
```
/hosts/               - Per-machine NixOS configurations
/modules/nixos/       - Shared NixOS modules
/modules/home/        - Shared Home Manager modules
/secrets/             - SOPS-encrypted secrets (age encryption)
/lib/                 - Helper functions (e.g., Podman network creation)
```

### Hosts

| Host | Role | Key Details |
|------|------|-------------|
| rumnas | Home Server/NAS | RAID (btrfs at /mnt/raid), NVIDIA GPU, runs containerized services |
| rumtower | Gaming/Workstation | KDE Plasma + SDDM Wayland, Firefly finance, PostgreSQL, CIFS mount |
| rumprism | Laptop | Intel iGPU, Niri Wayland experimental |
| saibaman | Remote Gateway | Borg backup destination |
| nosk | VPS | Nextcloud, static sites (rutrum.net, stringcase.org) |
| rumpi | 3D Printer | OctoPrint (mostly unused) |
| standalone | Home Manager only | User config only |

### Services

| Service | Host | Port | Description |
|---------|------|------|-------------|
| Immich | rumnas | 2283 | Photo gallery |
| Jellyfin | rumnas | 8096 | Media server |
| Mealie | rumnas | 9000 | Recipe manager |
| Grafana | rumnas | 3000 | Visualization |
| Prometheus | rumnas | 9090 | Metrics |
| Loki | rumnas | 3100 | Log aggregation |
| AdGuard Home | rumnas | 3001 | DNS filtering |
| Paperless-NGX | rumnas | 8000 | Document management |
| Dashy | rumnas | 8180 | Dashboard |
| FreshRSS | rumnas | 8085 | RSS aggregator |
| NocoDB | rumnas | 8081 | No-code database |
| RomM | rumnas | 8087 | ROM manager |
| qBittorrent | rumnas | 9009 | VPN-confined torrent |
| Home Assistant | rumnas | 8082 | Home automation |
| Local-AI | rumnas | 8089 | Local LLM |
| Calibre-Web | rumnas | 8083 | Book library |
| ntfy | rumnas | 8888 | Push notifications |
| Firefly III | rumtower | 8080 | Finance tracker |
| Nextcloud | nosk | 443 | Cloud suite |

### Network

- **Tailscale:** rumnas (100.73.14.110), rumtower as exit nodes
- **LAN:** 192.168.50.0/24 (rumnas: .3)
- **DNS Split-Horizon:** AdGuard provides .3 for LAN, Tailscale IP for VPN clients

### Common Paths

- RAID: `/mnt/raid`
- Immich: `/mnt/raid/immich`
- Paperless: `/mnt/raid/services/paperless`
- Books: `/mnt/raid/homes/rutrum/books`

### Service Access

All services accessible via `*.rum.internal` through Caddy. Key endpoints:
- Dashboard: `rum.internal`
- Grafana: `grafana.rum.internal`

### Secrets

SOPS-nix with age encryption. Keys at: `/home/rutrum/.config/sops/age/keys.txt`

## Common Workflows

### Building the System

Don't ever switch the configuration.  But after changes to a system, you can test it with
```bash
nixos-rebuild build --flake .#<system>
```

### Using Packages from nixpkgs-unstable

In home-manager modules, use `pkgs-unstable.<package>` (provided via `_module.args` in `rutrum.nix` with `allowUnfree = true`). For example:

```nix
{ pkgs, pkgs-unstable, ... }: {
  # In home.packages
  home.packages = [
    pkgs-unstable.yt-dlp
  ];

  # Or for programs with a package option
  programs.opencode = {
    enable = true;
    package = pkgs-unstable.opencode;
  };
}
```

In NixOS modules, use `perSystem.nixpkgs-unstable.<package>` (note: this does not have `allowUnfree` configured).
