# rutrum's dots

This directory manages the configuration and deployment of my personal computers using [NixOS](https://wiki.nixos.org/wiki/Overview_of_the_NixOS_Linux_distribution).  It also manages my user configuration using [home-manager](https://github.com/nix-community/home-manager).  The organization of this repo follows the structure set by [numtide/blueprint](https://github.com/numtide/blueprint).

This also manages my [pi coding agent](https://pi.dev) configuration.

## Directory Structure

* `hosts/<hostname>/configuration.nix`: NixOS configuration for `<hostname>`
* `hosts/<hostname>/users/rutrum.nix`: home-manager configuration on `<hostname>`
* `modules/nixos`: shared NixOS modules
* `modules/home`: shared home-manager modules
* `secrets`: secret files encrypted with sops-nix
* `pi`: pi coding agent configuration

The modules are not polished, nor meant for external use.  They are simply used to break up parts of my configuration and share between hosts and users.  Similarly for any packages.

## Hosts

I manage a few host machines on my home network:

| Host | Description |
|------|-------------|
| rumnas | Home server / NAS |
| rumtower | Gaming and workstation |
| rumprism | Laptop |
| saibaman | WIP remote gateway |
| nosk | VPS (rutrum.net) |
| rumpi | Raspberry pi that's currently unused |
| standalone | Home manager only for non-NixOS hosts |
