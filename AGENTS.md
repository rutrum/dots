# AGENTS.md

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
  programs.claude-code = {
    enable = true;
    package = pkgs-unstable.claude-code;
  };
}
```

In NixOS modules, use `perSystem.nixpkgs-unstable.<package>` (note: this does not have `allowUnfree` configured).
