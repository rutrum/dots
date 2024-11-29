{ pkgs, config, ... }:
{
  imports = [
    ./bash.nix
    ./starship.nix
    ./neovim.nix
    ./nix.nix
  ];

  programs = {
    git = {
      enable = true;
      userEmail = "dave@rutrum.net";
      userName = "rutrum";
      extraConfig = {
        pull.rebase = false;
        init.defaultBranch = "main";
      };
    };

    dircolors.enable = true;

    zoxide = {
      enable = true;
      enableBashIntegration = true;
    };

    zellij = {
      enable = true;
      # this enables zellij on shell startup
      #enableBashIntegration = true;
      settings = {
        theme = "catppuccin-mocha";
      };
    };

    atuin = {
      enable = true;
      enableBashIntegration = true;
    };

    htop = {
      enable = true;
      settings = {
        hide_kernel_threads = true;
        hide_userland_threads = true;
        show_program_path = false;
      };
    };
  };

  home.packages = with pkgs; [
    just

    ripgrep
    bat
    fd
    
    # encryption
    age
    sops

    # disks
    ncdu
    du-dust

    tealdeer
    fzf
    jq # traverse json
    pandoc # document conversion
    watchexec
    yt-dlp
    neofetch
    tree
    trash-cli
    wget
    cmus
    unzip
    yazi # terminal file browser
    ueberzugpp # for yazi terminal image previews
    python3
  ];
}
