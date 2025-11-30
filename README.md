# rutrum's dots

This directory manages the configuration and deployment of my personal computers using [NixOS](https://wiki.nixos.org/wiki/Overview_of_the_NixOS_Linux_distribution).  It also manages my user configuration using [home-manager](https://github.com/nix-community/home-manager).  The organization of this repo follows the structure set by [numtide/blueprint](https://github.com/numtide/blueprint).

## Directory Structure

* `hosts/<hostname>/configuration.nix`: the NixOS configuration for `hostname`
* `modules/nixos`: NixOS modules
* `hosts/<hostname>/users/rutrum.nix`: home-manager configuration on `hostname`
* `modules/home`: home-manager modules
* `secrets`: contains secret files encrypted with sops-nix

The modules are not polished, nor meant for external use.  They are simply used to break up parts of my configuration and share between hosts and users.

## Hosts

I manage a few host machines on my home network:
* `rumtower`: my gaming and main productivity rig
* `rumprism`: my laptop for light productivity work
* `rumnas`: my home NAS and server
* `rumpi`: my Raspberry Pi 4 that is unused
* `saibaman`: a remote gateway for troubleshooting and automation
