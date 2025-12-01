{...}: {
  programs.git = {
    enable = true;
    # TODO: set these in config and reference
    settings = {
      user.email = "dave@rutrum.net";
      user.name = "rutrum";
      pull.rebase = false;
      init.defaultBranch = "main";
    };
  };

  catppuccin.gitui.enable = true;
  programs.gitui.enable = true;
}
