# My Home-Manager Configuration

Still a work in progress.  I think you can get started by downloading the repo, nix and home-manager, enabling flakes, then running

```
home-manager switch --flake .
```

## From scratch

On a new NixOS installation, run this.

```
nix-shell -p git home-manager ...
git clone asdfasdfasdf
cd ~/dots
home-manager switch --flake .
```

## Maybe overview

* `hosts`: machine specific NixOS configurations
* `users`: user specific home-manager configurations
* `programs`: home manager modules for specific applications
* `services`: home manager modules for specific services

Should probably change to distinguish home-manager vs nixos modules
