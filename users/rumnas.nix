{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./rutrum.nix

    ./modules/cli
    ./modules/ssh.nix
    ./modules/games.nix
    ./modules/joystick.nix
    ./modules/terminal

    ./modules/browser.nix
  ];

  # for nvidia drivers
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    mdadm # for raid
  ];

  home.stateVersion = "23.05";
}
