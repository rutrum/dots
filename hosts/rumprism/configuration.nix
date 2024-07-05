{ config, pkgs, ... }:
{
  imports =
  [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../modules/tailscale.nix
  ];

  services.mullvad-vpn.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "rumprism";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Indiana/Indianapolis";

  # Select internationalisation properties.
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

  virtualisation = {
    podman = {
      enable = true;
      defaultNetwork.settings.dns_enabled = true;
      dockerSocket.enable = true;
    };
    oci-containers.backend = "podman";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Add flake registries nixpkgs stable
  nix.registry = {
    #nixpkgs-stable = {
    #  to = "github:NixOS/nixpkgs/nixos-23.05";
    #};
  };

  # GPU stuff
  hardware.opengl.enable = true;

  # printing
  services.printing.enable = true; # enables printing support via the CUPS daemon
  services.avahi.enable = true; # runs the Avahi daemon
  services.avahi.nssmdns = true; # enables the mDNS NSS plug-in
  services.avahi.openFirewall = true; # opens the firewall for UDP port 5353

  # services.avahi = {
  #   enable = true;
  #   nssmdns = true;
  #   openFirewall = true;
  # };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Do this stuff with home-manager
  # Enable the Cinnamon Desktop Environment.
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.cinnamon.enable = true;
  services.xserver.windowManager.xmonad = {
    enable = true;
    enableContribAndExtras = true;
  };

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # displaylink drivers for wavlink doc
  nixpkgs.config.allowUnfree = true;
  services.xserver.videoDrivers = [ "modesetting" ];

  services.logind.extraConfig = ''
    IdleAction=hybrid-sleep
    IdleActionSec=30min
    HandlePowerKey=ignore
  '';

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.rutrum.isNormalUser = true;
  # above was in example, but I might need?
  users.users.rutrum = {
    isNormalUser = true;
    description = "rutrum";
    extraGroups = [ "networkmanager" "wheel" ];
  };
  #home-manager.users.rutrum = { pkgs, ... }: {
  #  home.packages = [ pkgs.polybar ];
  #  programs.bash.enable = true;
  #};

  environment.systemPackages = with pkgs; [
    git
    home-manager
    neovim
    rxvt-unicode
  ];

  # programs.firefox = {
  #   enable = true;
  #   policies = {
  #     "DisablePocket" = true;
  #     "DisableTelemetry" = true;
  #     "PasswordManagerEnabled" = false;
  #   };
  # };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
