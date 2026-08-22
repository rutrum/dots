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
  home.file.".npmrc".text = ''
    prefix=${config.home.homeDirectory}/.npm-global
  '';

  home.sessionPath = ["${config.home.homeDirectory}/.npm-global/bin"];

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
      nodejs
      flake.inputs.llm-agents.packages.${pkgs.system}.qmd
    ]
    ++ lib.optionals gui.enable [
      flake.packages.${pkgs.system}.agent-browser
    ];
}
