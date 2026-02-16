{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./static-sites.nix
    ./nextcloud.nix

    inputs.self.nixosModules.system
  ];

  networking.hostName = "nosk";

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Open ports for HTTP, HTTPS, and webhook
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      80 # HTTP
      443 # HTTPS
      9000 # Webhooks
    ];
  };

  # Add caddy user to webhook group for file permissions
  users.users.caddy.extraGroups = ["webhook"];

  # Disable flatpak for server (comes from system module)
  services.flatpak.enable = lib.mkForce false;

  # System packages
  environment.systemPackages = with pkgs; [
    git
    neovim
    home-manager
    hugo
    zola
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # From nixos-infect

  # Workaround for https://github.com/NixOS/nix/issues/8502
  services.logrotate.checkConfig = false;

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIb4sr8jfAagDEYJQg1Xa9WN1i+jQFzEnSvU/e1X4oed rutrum@rumtower''];
  system.stateVersion = "23.11";
}
