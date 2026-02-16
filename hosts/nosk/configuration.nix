{
  config,
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

  system.stateVersion = "25.11";
}
