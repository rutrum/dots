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

  config = let
    shellAliases = {
      v = "nvim";
      j = "just";
      f = "fuck";
      py = "python3";

      jf = "journalctl -f -u";
      wt = "watchexec --clear=reset --restart -w";

      # prompt on file overwrite
      cp = "cp -i";
      mv = "mv -i";

      # colors
      less = "less -R";
      ls = "eza";
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
    };
  in {
    catppuccin.fish.enable = true;

    programs.fish = {
      enable = true;
      inherit shellAliases;

      interactiveShellInit = ''
        set fish_greeting

        function nsn
          nix shell nixpkgs#"$argv"
        end
        function nrn
          nix run nixpkgs#"$argv"
        end

      '';
    };

    programs.nushell = {
      enable = true;
    };

    programs.bash = {
      enable = true;
      inherit shellAliases;

      # https://nixos.wiki/wiki/Fish#Setting_fish_as_your_shell
      initExtra = ''
        if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
        then
          shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
          exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
        fi
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
    };
  };
}
