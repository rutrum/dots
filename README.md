# My Home-Manager Configuration

Still a work in progress.  I think you can get started by downloading the repo, nix and home-manager, enabling flakes, then running

```
home-manager switch --flake .
```

## From Scratch

### NixOS

On a new NixOS installation, run this from the home directory.

```
nix-shell -p git home-manager ...
git clone asdfasdfasdf
cd ~/dots
home-manager switch --flake .#rutrum
```

Then run `snrs` to load the system configuration.

### Just Home Manager configuration

Be sure to install nix.  Run above.

## Directory Structure

* `hosts`: machine specific NixOS configurations
* `hosts/modules`: NixOS modules
* `users`: user specific home-manager configurations
* `users/modules`: home-manager modules

## Hosts and Users

I want to manage 3 NixOS configurations:
* `rumtower`: my gaming and main productivity rig
* `rumprism`: my laptop for light productivity work
* `rumnas`: my home NAS and server

Similarly, 3 home-manager configurations:
* `rutrum@rumtower`
* `rutrum@rumprism`
* `rutrum`: for every other system, including non-nixos systems, like my work laptop
