{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: let
  unstable-unfree = import inputs.nixpkgs-unstable {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };
in {
  disabledModules = ["${inputs.nixpkgs-stable}/nixos/modules/services/misc/ollama.nix"];
  imports = [
    "${inputs.nixpkgs-unstable}/nixos/modules/services/misc/ollama.nix"
  ];

  options.me.llm = {
    enable-open-webui = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  config.services = {
    open-webui = {
      host = "0.0.0.0";
      package = pkgs.open-webui;
      port = 8080;
      enable = config.me.llm.enable-open-webui;
      openFirewall = true;
    };

    ollama = {
      package = unstable-unfree.ollama-cuda;
      host = "0.0.0.0";
      port = 11434;
      enable = true;
      acceleration = "cuda";
    };
  };
}
