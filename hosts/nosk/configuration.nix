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
  ];

  networking.hostName = "nosk";

  # Basic nix settings
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
  };

  nixpkgs.config.allowUnfree = true;

  # Locale settings
  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password"; # Allow root with SSH key only
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

  # System packages
  environment.systemPackages = with pkgs; [
    git
    neovim
    home-manager
    hugo
    zola
  ];

  # From nixos-infect

  # Workaround for https://github.com/NixOS/nix/issues/8502
  services.logrotate.checkConfig = false;

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  networking.domain = "";
  users.users.root.openssh.authorizedKeys.keys = [''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIb4sr8jfAagDEYJQg1Xa9WN1i+jQFzEnSvU/e1X4oed rutrum@rumtower''];
  system.stateVersion = "23.11";
}
