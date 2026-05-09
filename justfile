# dots justfile

# List available recipes
default:
    @just --list

# Build a host configuration without switching (safe, local check)
build host:
    nixos-rebuild build --flake .#{{ host }}

# Deploy nosk — builds locally, switches remotely via sudo
deploy-nosk:
    nixos-rebuild switch --flake .#nosk --target-host rutrum@rutrum.net --sudo
