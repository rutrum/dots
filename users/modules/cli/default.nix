inputs:
{ pkgs, config, ... }:
{
  imports = [
    ./bash.nix
    ./starship.nix
    (import ./neovim.nix inputs)
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

    zellij = {
      enable = true;
      # this enables zellij on shell startup
      #enableBashIntegration = true;
      settings = {
        theme = "catppuccin-mocha";
      };
    };
  };

  # GPG program for making PGP keys
  programs.gpg.enable = true;
  services.gpg-agent = {
    pinentryPackage = pkgs.pinentry-curses;
    enable = true;
    enableBashIntegration = true;
    enableSshSupport = true;
  };

  home.packages = with pkgs; [
    just
    ripgrep
    pandoc
    tealdeer
    bat
    fd
    jq
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
    fzf
    yazi # terminal file browser
    ueberzugpp # for yazi terminal image previews
    python3
  ];
}
