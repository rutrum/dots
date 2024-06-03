{ ... }:
{
  services.tabby = {
    enable = true;
    port = 11029;
    acceleration = "cuda"; # should default to cuda? maybe cpu
  };
  networking.firewall.allowedTCPPorts = [ 11029 ];
}
