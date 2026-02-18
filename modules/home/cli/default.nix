{
  pkgs,
  config,
  ...
}: {
  imports = [
    ./shell.nix
    ./starship.nix
    ./neovim.nix
    ./git.nix
  ];

  catppuccin = {
    btop.enable = true;
    #eza.enable = true;
    yazi.enable = true;
    zellij.enable = true;
  };

  programs = {
    dircolors.enable = true;

    # todo: read more about how to set this up
    # https://github.com/nix-community/nix-index
    nix-index = {
      enable = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
    };

    eza = {
      enable = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
    };

    btop = {
      enable = true;
    };

    pay-respects = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
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
      enableFishIntegration = true;
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
      enableFishIntegration = true;
    };

    claude-code = {
      enable = true;
    };

    opencode = {
      enable = true;
    };

    yazi = {
      enable = true;

      enableFishIntegration = true;
      enableBashIntegration = true;

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

    # RIIR
    ripgrep
    bat
    typos # source code spell checker

    # encryption
    age
    sops

    # disks
    ncdu
    dust

    # data processing
    jq # traverse json
    pandoc # document conversion
    duckdb

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

  home.sessionVariables = {
    CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1";
  };
}
