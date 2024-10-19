{ pkgs, inputs, ... }:
{
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

  services = {
    tailscale.enable = true;
    mullvad-vpn = {
      enable = true;
      package = pkgs.mullvad-vpn; # includes GUI
    };
    flatpak.enable = true;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.networkmanager.enable = true;

  programs.nh = {
    enable = true;
    flake = "/home/rutrum/dots";
  };

  users.users.rutrum = {
    isNormalUser = true;
    description = "rutrum";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
  };

  environment.systemPackages = with pkgs; [
    neovim 
    git 
    home-manager
    rxvt-unicode
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
