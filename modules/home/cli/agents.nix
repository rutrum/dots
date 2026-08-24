{
  pkgs,
  config,
  pkgs-unstable,
  lib,
  flake,
  inputs,
  ...
}: let
  inherit (config.me) gui;
in {
  home.file.".npmrc".text = ''
    prefix=${config.home.homeDirectory}/.npm-global
  '';

  home.sessionPath = ["${config.home.homeDirectory}/.npm-global/bin"];

  home.file.".pi/agent/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dots/pi/settings.json";
  home.file.".pi/agent/models.json".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dots/pi/models.json";
  home.file.".pi/agent/extensions".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dots/pi/extensions";
  home.file.".agents/skills".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dots/pi/skills";

  programs = {
    opencode = {
      enable = true;
      package = pkgs-unstable.opencode;
    };
  };

  home.packages = with pkgs;
    [
      inputs.llm-agents.packages.${pkgs.system}.pi
      nodejs
      flake.inputs.llm-agents.packages.${pkgs.system}.qmd
    ]
    ++ lib.optionals gui.enable [
      flake.packages.${pkgs.system}.agent-browser
    ];
}
