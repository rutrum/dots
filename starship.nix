{
  enable = true;
  enableBashIntegration = true;
  enableFishIntegration = true;
  settings = {
    format = ''
      $username$nix_shell$directory$character
    '';
    add_newline = false;
    nix_shell = {
      format = "[\\[$name\\]]($style) ";
    };
    character = {
      success_symbol = "[\\$](bold white)";
      error_symbol = "[?](bold white)";
    };
    directory = {
      truncate_to_repo = true;
      truncation_symbol = "";
    };
  };
}
