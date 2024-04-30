unstable:
{ ... }:
{
  services.tabby = {
    package = unstable.legacyPackages.x86_64-linux.tabby;
    enable = true;
    port = 11029;
    acceleration = null; # should default to cuda? maybe cpu
  };
  networking.firewall.allowedTCPPorts = [ 11029 ];
}
