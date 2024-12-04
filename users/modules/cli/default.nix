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

    thefuck = {
      enable = true;
      enableBashIntegration = true;
    };

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

    gitui = {
      enable = true;
      # https://github.com/catppuccin/gitui/blob/main/themes/catppuccin-macchiato.ron
      theme = ''
        (
          selected_tab: Some("Reset"),
          command_fg: Some("#cad3f5"),
          selection_bg: Some("#5b6078"),
          selection_fg: Some("#cad3f5"),
          cmdbar_bg: Some("#1e2030"),
          cmdbar_extra_lines_bg: Some("#1e2030"),
          disabled_fg: Some("#8087a2"),
          diff_line_add: Some("#a6da95"),
          diff_line_delete: Some("#ed8796"),
          diff_file_added: Some("#a6da95"),
          diff_file_removed: Some("#ee99a0"),
          diff_file_moved: Some("#c6a0f6"),
          diff_file_modified: Some("#f5a97f"),
          commit_hash: Some("#b7bdf8"),
          commit_time: Some("#b8c0e0"),
          commit_author: Some("#7dc4e4"),
          danger_fg: Some("#ed8796"),
          push_gauge_bg: Some("#8aadf4"),
          push_gauge_fg: Some("#24273a"),
          tag_fg: Some("#f4dbd6"),
          branch_fg: Some("#8bd5ca")
        )
      '';
    };

    htop = {
      enable = true;
      # htop overwrites the file all the time, causing home manager
      # to write backups all the time
      #settings = {
      #  hide_kernel_threads = true;
      #  hide_userland_threads = true;
      #  show_program_path = false;
      #};
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
    yazi # terminal file browser
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

    tealdeer
    fzf
    jq # traverse json
    pandoc # document conversion
    watchexec
    yt-dlp
    neofetch
    trash-cli
    wget
    cmus
    python3
  ];
}
