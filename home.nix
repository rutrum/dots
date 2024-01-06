{ config, pkgs, pkgs-stable, anki-bin, eww-repo, ... }@inputs: let
  terminal = "urxvt";
in {
  
  imports = [
    ./programs/urxvt.nix
    ./programs/bash.nix
    ./programs/alacritty.nix
    ./programs/starship.nix
  ];

  bash.terminal = "alacritty"; # should probably find a better spot for this

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

  # for nvidia drivers
  nixpkgs.config.allowUnfree = true;

  home.sessionPath = [
    "/home/rutrum/.nix-profile/bin"
  ];

  fonts.fontconfig.enable = true;

  # requires xserver enabled in system config
  # xsession = {
    # enable = true;

    # windowManager.herbstluftwm = import ./herbstluftwm.nix { 
    #   pkgs = pkgs-stable; 
    #   terminal = terminal;
    # };
    # windowManager.xmonad.enable = true;

    # windowManager.awesome.enable = true;
  # };

  # home.file.awesome = {
    # source = config.lib.file.mkOutOfStoreSymlink ./awesome.lua;
    # target = ".config/awesome/rc.lua";
  # };

  home.file.xmonad = {
    source = ./xmonad.hs;
    target = ".config/xmonad/xmonad.hs";
  };

  # Home Directories

  # symlink my music directory
  home.file.music = {
    source = config.lib.file.mkOutOfStoreSymlink "/mnt/barracuda/media/music";
    target = "music";
  };

  xdg.userDirs = {
    enable = true;
    createDirectories = true;

    desktop = "${config.home.homeDirectory}/desktop";
    documents = null;
    download = "${config.home.homeDirectory}/downloads";
    music = "${config.home.homeDirectory}/music";
    pictures = null;
    publicShare = null;
    templates = null;
    videos = null;
  };

  nix.registry = {
    # redo nixpkgs to be stable
    nixpkgs = {
      from = {
        type = "indirect";
        id = "nixpkgs";
      };
      to = {
        type = "github";
        owner = "NixOS";
        repo = "nixpkgs";
        ref = "nixos-23.11"; # TODO: make this a variable somewhere
      };
    };

    # add nixpkgs unstable
    unstable = {
      from = {
        type = "indirect";
        id = "unstable";
      };
      to = {
        type = "github";
        owner = "NixOS";
        repo = "nixpkgs";
        ref = "nixos-unstable";
      };
    };
  };

  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    neovim = import ./programs/neovim.nix { inherit pkgs; };
    firefox = import ./programs/firefox.nix { inherit (inputs) firefox-addons pkgs-stable; };

    git = {
      enable = true;
      userEmail = "dave@rutrum.net";
      userName = "rutrum";
      extraConfig = {
        pull.rebase = false;
      };
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
          hostname = "45.63.65.162";
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
    mullvad-browser
    # todo
    # thunderbird
    zathura
    flameshot
    gimp
    gnome.simple-scan
    nextcloud-client
    discord
    libreoffice
    sxiv
    pavucontrol
    anki-bin
    font-manager
    bitwarden

    # gaming
    steam

    # 3d printing
    cura # needs nvidia drivers in nix
    # openscad # beta installed through flatpak

    # graphics stuff
    #nixgl.auto.nixGLNvidia

    # fonts
    nerdfonts
    noto-fonts-emoji
    iosevka-bin

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
    cmus
    unzip
    yazi # terminal file browser
    ueberzugpp # for yazi terminal image previews

    # container and virtual machines
    distrobox
    # podman
    # podman-compose

    pods # ui for podman

    # ricing
    feh

    # hardware utilities
    acpi
    brightnessctl

    # dont exist yet with nixpkgs, but cargo install works
    #vtracer toml-cli ytop checkexec

    # my flakes
    # inputs.wasm4
  ];


  services = {
    # flatpak stuff: https://github.com/GermanBread/declarative-flatpak/blob/dev/docs/definition.md
    flatpak = {
      enableModule = true;
      packages = [
        "flathub:app/info.beyondallreason.bar//master"
        "flathub:app/org.openscad.OpenSCAD//beta"
      ];
    };

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
    # nixos thing!: syncthing = import ./services/syncthing.nix {};
  };
}
