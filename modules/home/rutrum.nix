{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  # This is the base rutrum config that all other rutrum_system configs include.
  # It is also a standalone headless user configuration (such as raspberry pi servers
  # or WSL) which means there shouln't be any GUI applications

  imports = [
    inputs.flatpaks.homeModules.default
    inputs.nixvim.homeManagerModules.nixvim
    inputs.catppuccin.homeModules.catppuccin

    ../../users/ui.nix
    ../../users/modules/cli
    ../../users/modules/ssh.nix
  ];

  config = {
    me = {
      terminal = "alacritty";
      ui.enable = false;
    };

    # Home Manager needs a bit of information about you and the
    # paths it should manage.
    home = {
      username = "rutrum";
      homeDirectory = "/home/rutrum";

      shell.enableFishIntegration = true;
    };

    services = {
      # flatpak stuff: https://github.com/GermanBread/declarative-flatpak/blob/dev/docs/definition.md
      flatpak = {
        enableModule = true;
        remotes = {
          "flathub" = "https://dl.flathub.org/repo/flathub.flatpakrepo";
          "flathub-beta" = "https://dl.flathub.org/beta-repo/flathub-beta.flatpakrepo";
        };
      };
    };

    catppuccin.flavor = "mocha";

    xdg.userDirs = {
      enable = true;
      createDirectories = true;

      desktop = "${config.home.homeDirectory}/desktop";
      documents = null;
      download = "${config.home.homeDirectory}/downloads";
      music = "${config.home.homeDirectory}/music";
      pictures = null;
      publicShare = null;
      templates = null;
      videos = null;
    };

    programs = {
      home-manager.enable = true;

      ssh = {
        enable = true;
        matchBlocks = {
          vultr = {
            hostname = "45.63.65.162";
          };
        };
      };
    };

    home.packages = with pkgs; [
      appimage-run
      distrobox
      pdftk

      # networking
      dig
      dnsutils
      lftp # ftps client
    ];

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    home.stateVersion = "23.05";
  };
}
