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

  xsession = {
    enable = true;
    # profileExtra = ''
    #     PATH=$PATH:/home/rutrum/.nix-profile/bin
    # '';
    # windowManager.herbstluftwm = import ./herbstluftwm.nix { 
    #   pkgs = pkgs-stable; 
    #   terminal = terminal;
    # };
  };

  # neovim config
  # xdg.configFile.nvim = {
  #   source = ./neovim;
  #   recursive = true;
  # };

  programs.neovim = import ./neovim.nix { inherit pkgs; };

  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;

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

    urxvt = import ./urxvt.nix;
    starship = import ./starship.nix;
    firefox = import ./firefox.nix { inherit (inputs) firefox-addons; };

    # fish = {
    # enable = true;
    # };

    bash = {
      enable = true;
      initExtra = ''
        # Opens a file in the default program.
        open () {
          xdg-open "$1" & &> /dev/null
        }

        # ^S no longer pauses terminal
        stty -ixon

        PATH=/home/rutrum/.nix-profile/bin:$PATH
      '';
      shellAliases = {
        v = "nvim";
        j = "just";
        py = "python3";

        # don't overwrite files or prompt
        cp = "cp -i";
        mv = "mv -i";

        # colors
        less = "less -R";
        ls = "ls --color=auto";
        grep = "grep --color=auto";

        # print human readable sizes
        du = "du -h";
        df = "df -h";
        ll = "ls -lhF";

        hms = "home-manager switch --flake ~/dots";
        nd = "nix develop";

        clone = "(pwd | ${terminal} & disown \$!)";
      };
    };

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
    # firefox
    zathura
    flameshot
    gimp

    # 3d printing
    # cura # needs nvidia drivers in nix

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

    # dont exist yet with nixpkgs, but cargo install works
    #vtracer toml-cli ytop checkexec

    # doesn't work without gpu shinanigans
    # alacritty

    # my flakes
    inputs.wasm4
  ];

  services = {
    picom = {
      enable = true;
      settings = {
        # fix for nvidia: https://nixos.wiki/wiki/Nvidia
        unredir-if-possible = false;
        backend = "xrender";
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

    polybar = import ./polybar.nix {};
  };
}
