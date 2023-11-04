{ terminal }:
{
  enable = true;
  initExtra = ''
    # Opens a file in the default program.
    open () {
      xdg-open "$1" & &> /dev/null
    }

    # ^S no longer pauses terminal
    stty -ixon
  '';
  profileExtra = ''
    # add nix application desktop files
    XDG_DATA_DIRS=$HOME/.nix-profile/share:"''${XDG_DATA_DIRS}"
    PATH=/home/rutrum/.nix-profile/bin:$PATH
  '';
  shellAliases = {
    v = "nvim";
    j = "just";
    py = "python3";

    # don't overwrite files or prompt
    cp = "cp -i";
    mv = "mv -i";

    # colors
    less = "less -R";
    ls = "ls --color=auto";
    grep = "grep --color=auto";

    # print human readable sizes
    du = "du -h";
    df = "df -h";
    ll = "ls -lhF";

    hms = "home-manager switch --flake ~/dots";
    snrs = "sudo nixos-rebuild switch --flake ~/dots";
    nd = "nix develop";

    clone = "(pwd | ${terminal} & disown \$!)";
  };
}
