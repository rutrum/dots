{
  config,
  lib,
  pkgs,
  ...
}: {
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
      ll = "ls -lhgA";

      # navigation
      cdf = "cd $(fzf)";

      # nix shortcuts
      snrs = "sudo nixos-rebuild switch --flake ~/dots";
      nd = "nix develop";
    };
  in {
    catppuccin.fish.enable = true;

    programs = {
      nushell.enable = true;

      fish = {
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

      bash = {
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
          VISUAL='nvim'
          EDITOR='nvim'
        '';
      };
    };
  };
}
