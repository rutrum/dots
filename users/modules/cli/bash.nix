{ config, lib, ... }: 
with lib;
let
  cfg = config.bash;
in {
  options = {
    bash.terminal = mkOption {
      type = types.str;
      description = ''
        The default terminal.
      '';
    };
  };

  config = {
    programs.bash = {
      enable = true;
      initExtra = ''
        # Opens a file in the default program.
        open () {
          xdg-open "$1" & &> /dev/null
        }

        # ^S no longer pauses terminal
        stty -ixon

        nrn () {
          nix run nixpkgs#"$1"
        }
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
        py3 = "python3";

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

        clone = "(pwd | ${cfg.terminal} & disown \$!)";

        # distrobox applications
        w4 = "distrobox enter deb -- w4";

        nixgl = "NIXPKGS_ALLOW_UNFREE=1 nix run --impure github:guibou/nixGL --";
      };
    };
  };
}
