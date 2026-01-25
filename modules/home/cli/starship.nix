{
  catppuccin.starship.enable = true;

  programs.starship = {
    enable = true;

    enableBashIntegration = true;
    enableFishIntegration = true;

    settings = {
      format = ''
        $env_var$username$hostname$nix_shell$git_branch$directory$character
      '';
      add_newline = false;

      username = {
        # only show if different from logged-in user or on ssh
        show_always = false;
        format = "[$user]($style)";
        style_user = "bold yellow";
      };

      hostname = {
        # show on ssh connections
        ssh_only = true;
        format = "[@$hostname]($style) ";
        style = "bold yellow";
      };

      nix_shell = {
        format = "[\\[$name\\]]($style) ";
        heuristic = true;
      };

      character = {
        success_symbol = "[\\$](bold white)";
        error_symbol = "[?](bold white)";
      };

      directory = {
        truncate_to_repo = true;
        truncation_symbol = "";
        read_only = " (ro)";
        read_only_style = "bold red";
      };

      git_branch = {
        format = "[$branch]($style) ";
      };

      # for distrobox
      env_var.CONTAINER_ID = {
        format = "[distrobox:$env_value ](bold yellow)";
      };
    };
  };
}
