{
  pkgs,
  config,
  ...
}: {
  imports = [
    ./bash.nix
    ./starship.nix
    ./neovim.nix
    ./nix.nix
    ./git.nix
  ];

  catppuccin = {
    zellij.enable = true;
    yazi.enable = true;
    btop.enable = true;
  };

  programs = {
    dircolors.enable = true;

    btop = {
      enable = true;
    };

    thefuck = {
      enable = true;
      enableBashIntegration = true;
    };

    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
      silent = true;
    };

    zoxide = {
      enable = true;
      enableBashIntegration = true;
    };

    zellij = {
      enable = true;
      settings = {
        show_startup_tips = false;
      };
    };

    atuin = {
      enable = true;
      enableBashIntegration = true;
    };

    yazi = {
      enable = true;

      settings = {
        manager = {
          ratio = [1 3 4];
        };
        preview = {
          wrape = "yes";
        };
      };
    };
  };

  home.packages = with pkgs; [
    just

    # compression
    ouch # all-in-one compression utility
    unzip

    # file system
    gdu # tui to explore directory sizes
    tree
    ueberzugpp # for yazi terminal image previews
    fd
    du-dust

    # RIIR
    ripgrep
    bat

    # encryption
    age
    sops

    # disks
    ncdu
    du-dust

    # data processing
    jq # traverse json
    pandoc # document conversion
    duckdb
    pandoc # document conversion

    tealdeer
    fzf
    watchexec
    yt-dlp
    neofetch
    trash-cli
    wget
    cmus
    python3
    mediainfo
    csvlens # csv tui
    slumber # rest client
  ];
}
