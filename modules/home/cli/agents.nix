{
  pkgs,
  config,
  pkgs-unstable,
  lib,
  flake,
  ...
}: let
  inherit (config.me) gui;
in {
  programs = {
    opencode = {
      enable = true;
      package = pkgs-unstable.opencode;
    };
  };

  home.packages = with pkgs;
    [
      pkgs-unstable.beads
      pkgs-unstable.pi-coding-agent
    ]
    ++ lib.optionals gui.enable [
      flake.packages.${pkgs.system}.agent-browser
    ];
}
