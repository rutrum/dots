{ ... }:
{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      vultr = {
        hostname = "45.63.65.162";
      };
      thomas = {
        hostname = "thomas.butler.edu";
        user = "dpurdum";
      };
      bigdawg = {
        hostname = "bigdawg.butler.edu";
        user = "dpurdum";
      };
    };
  };
}
