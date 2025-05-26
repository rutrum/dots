{
  pkgs,
  inputs,
  ...
}: {
  # Base system config for all NixOS configurations

  # TODO: create wayland/xorg/DE modules

  imports = [
    inputs.sops-nix.nixosModules.sops
    ./modules/syncthing.nix
  ];

  sops.defaultSopsFile = ../secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/home/rutrum/.config/sops/age/keys.txt";

  # does this need to be system configuration?
  # it's for user applications afterall
  #services.flatpak.enable = true;

  # TODO: consider removing
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # local binary cache
  nix.settings = {
    substituters = [
      "http://192.168.50.3:9999"
    ];
    trusted-public-keys = [
      "key-name:tXEK2NB+ic7kY8f+FgQ2kqZ/aY8HLuDdLsvKB68cuKU="
    ];
  };
  nix.settings.experimental-features = ["nix-command" "flakes"];

  services = {
    tailscale.enable = true;
    mullvad-vpn.package = pkgs.mullvad-vpn; # default package excludes UI
    mullvad-vpn.enable = true;
    flatpak.enable = true;
  };

  fonts.fontDir.enable = true;

  # networking
  networking.networkmanager.enable = true;
  systemd.services.NetworkManager-ensure-profiles.after = ["NetworkManager.service"];
  systemd.services.NetworkManager-wait-online.enable = false;

  users.users.rutrum = {
    isNormalUser = true;
    description = "rutrum";
    extraGroups = ["networkmanager" "wheel" "docker"];
  };

  environment.systemPackages = with pkgs; [
    neovim
    git
    home-manager
  ];

  # Locale settings
  time.timeZone = "America/Indiana/Indianapolis";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
}
