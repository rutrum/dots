{
  config,
  lib,
  pkgs,
  ...
}: {
  options.me = {
    terminal = lib.mkOption {
      type = lib.types.str;
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

        nsn () {
          nix shell nixpkgs#"$1"
        }
        nrn () {
          nix run nixpkgs#"$1"
        }

        # just completions
        eval "$(${pkgs.just}/bin/just --completions bash)"
        # j completions
        complete -F _just -o bashdefault -o default j
      '';
      profileExtra = ''
        # add nix application desktop files
        XDG_DATA_DIRS=$HOME/.nix-profile/share:"''${XDG_DATA_DIRS}"
        PATH=/home/rutrum/.nix-profile/bin:$PATH
        VISUAL='nvim'
        EDITOR='nvim'
      '';
      shellAliases = {
        v = "nvim";
        j = "just";
        f = "fuck";
        py = "python3";

        # prompt on file overwrite
        cp = "cp -i";
        mv = "mv -i";

        # colors
        less = "less -R";
        ls = "ls --color=auto";
        grep = "grep --color=auto";

        # print human readable sizes
        du = "du -h";
        df = "df -h";
        ll = "ls -lhA";

        # navigation
        cdf = "cd $(fzf)";

        # nix shortcuts
        hms = "home-manager switch --flake ~/dots";
        snrs = "sudo nixos-rebuild switch --flake ~/dots";
        nd = "nix develop";

        clone = "(pwd | ${config.me.terminal} & disown \$!)";
      };
    };
  };
}
