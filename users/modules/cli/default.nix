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
      };
    };

    dircolors.enable = true;

    zoxide = {
      enable = true;
      enableBashIntegration = true;
    };
  };

  home.packages = with pkgs; [
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
    nvtop
    wget
    cmus
    unzip
    yazi # terminal file browser
    ueberzugpp # for yazi terminal image previews
  ];
}
