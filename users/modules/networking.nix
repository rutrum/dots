{ pkgs, ... }:
{
  home.packages = with pkgs; [
    dig
    dnsutils
    lftp # ftps client
  ];
}
