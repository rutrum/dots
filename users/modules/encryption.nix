{ pkgs, ... }:
{
  # additional packages for encryption
  home.packages = with pkgs; [
    sops
    age
  ];
}
