{ config, pkgs, pkgs-stable, eww-repo, ... }@inputs: let
  terminal = "urxvt";
in {
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "rutrum";
  home.homeDirectory = "/home/rutrum";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.05";

  home.sessionPath = [
    "/home/rutrum/.nix-profile/bin"
  ];

  fonts.fontconfig.enable = true;

  # xsession = {
    # enable = true;
    # profileExtra = ''
    #     PATH=$PATH:/home/rutrum/.nix-profile/bin
    # '';
    # windowManager.herbstluftwm = import ./herbstluftwm.nix { 
    #   pkgs = pkgs-stable; 
    #   terminal = terminal;
    # };
  # };

  home.file.xmonad = {
    source = ./xmonad.hs;
    target = ".config/xmonad/xmonad.hs";
  };

  # neovim config
  # xdg.configFile.nvim = {
  #   source = ./neovim;
  #   recursive = true;
  # };

  # for discord, nvidia drivers
  nixpkgs.config.allowUnfree = true;

  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    neovim = import ./programs/neovim.nix { inherit pkgs; };
    urxvt = import ./programs/urxvt.nix;
    bash = import ./programs/bash.nix { inherit terminal; };
    starship = import ./programs/starship.nix;
    firefox = import ./programs/firefox.nix { inherit (inputs) firefox-addons pkgs-stable; };

    git = {
      enable = true;
      userEmail = "dave@rutrum.net";
      userName = "rutrum";
    };

    rofi = {
      enable = true;
      extraConfig = {
        lines = 10;
        show-icons = true;
      };
      theme = "glue_pro_blue";
    };

    # status bar
    eww = {
      enable = true;
      configDir = "${eww-repo}/examples/eww-bar";
    };

    ssh = {
      enable = true;
      matchBlocks = {
        vultr = {
          hostname = "144.202.23.250";
        };
        thomas = {
          hostname = "thomas.butler.edu";
          user = "dpurdum";
        };
        bigdawg = {
          hostname = "bigdawg.butler.edu";
          user = "dpurdum";
        };
      };
    };

    # fish = {
    # enable = true;
    # };

    dircolors.enable = true;

    zoxide = {
      enable = true;
      enableBashIntegration = true;
    };
  };

  home.packages = with pkgs; [

    # graphical applications
    ungoogled-chromium
    # todo
    # thunderbird
    zathura
    flameshot
    gimp
    gnome.simple-scan
    qownnotes
    nextcloud-client
    discord
    libreoffice
    sxiv
    pavucontrol
    libsForQt5.dolphin # file manager

    # 3d printing
    cura # needs nvidia drivers in nix

    # graphics stuff
    #nixgl.auto.nixGLNvidia

    # fonts
    nerdfonts
    noto-fonts-emoji

    # command line utilities
    just
    ripgrep
    pandoc
    tealdeer
    bat
    fd
    du-dust
    watchexec
    yt-dlp
    neofetch
    tree
    trash-cli
    htop
    wget

    # container and virtual machines
    distrobox

    # ricing
    feh

    # hardware utilities
    acpi
    brightnessctl

    # dont exist yet with nixpkgs, but cargo install works
    #vtracer toml-cli ytop checkexec

    # doesn't work without gpu shinanigans
    # alacritty

    # my flakes
    # inputs.wasm4
  ];

  services = {
    picom = {
      enable = false;
      settings = {
        # fix for nvidia: https://nixos.wiki/wiki/Nvidia
        unredir-if-possible = false;
        backend = "xrender"; # this might be a problem for my laptop
        vsync = true;

        shadow = true;

        shadow-radius = 12;
        shadow-opacity = 0.3;
        shadow-offset-x = 0;
        shadow-offset-y = 0;
        shadow-exclude = [
          "name = 'Notification'"
        ];

        blur = {
          method = "gaussian";
          size = 10;
          deviation = 15.0;
        };
      };
    };

    # syncthing.enable = true;

    polybar = import ./services/polybar.nix {};
  };
}
