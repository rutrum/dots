{...}: {
  programs.git = {
    enable = true;
    # TODO: set these in config and reference
    userEmail = "dave@rutrum.net";
    userName = "rutrum";
    extraConfig = {
      pull.rebase = false;
      init.defaultBranch = "main";
    };
  };

  catppuccin.gitui.enable = true;
  programs.gitui.enable = true;
}
