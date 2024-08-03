{ pkgs, ... }:
{
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  programs.nh = {
    enable = true;
    flake = "/home/rutrum/dots";
  };
}
