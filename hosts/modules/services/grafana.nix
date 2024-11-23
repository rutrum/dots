{ pkgs, ... }:
{
  services.grafana = {
    enable = true;
    settings = {
      http_addr = "0.0.0.0";
      http_port = 3000;
      domain = "rumtower.lynx-chromatic.ts.net";
    };
  };
}
