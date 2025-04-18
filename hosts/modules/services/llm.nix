{inputs, ...}: let
  unstable-unfree = import inputs.nixpkgs-unstable {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };
in {
  disabledModules = ["${inputs.nixpkgs-stable}/nixos/modules/services/misc/ollama.nix"];
  imports = [
    "${inputs.nixpkgs-unstable}/nixos/modules/services/misc/ollama.nix"
  ];

  services.open-webui = {
    host = "0.0.0.0";
    package = unstable-unfree.open-webui;
    port = 8080;
    enable = true;
    openFirewall = true;
  };

  services.ollama = {
    package = unstable-unfree.ollama-cuda;
    host = "0.0.0.0";
    port = 11434;
    enable = true;
    acceleration = "cuda";
  };
}
