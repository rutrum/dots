{ inputs, ... }:
{
  services.open-webui = {
    host = "0.0.0.0";
    package = inputs.nixpkgs-unstable.legacyPackages.x86_64-linux.open-webui;
    port = 8080;
    enable = true;
    openFirewall = true;
  };

  services.ollama = {
    package = inputs.nixpkgs-unstable.legacyPackages.x86_64-linux.ollama;
    listenAddress = "0.0.0.0:11434";
    enable = true;
    acceleration = false;
  };
}
