# https://gist.github.com/vy-let/a030c1079f09ecae4135aebf1e121ea6
{ pkgs, ... }:
{
  services = {
    samba = {
      enable = true;
      openFirewall = true;
      package = pkgs.samba4Full;
      
      #syncPasswordsByPam = true;
      # You will still need to set up the user accounts to begin with:
      # $ sudo smbpasswd -a yourusername

      shares.testshare = {
        path = "/mnt/vault/testshare";
        writable = "true";
        comment = "Hello World!";
      };

      #shares = {
      #  homes = {
      #    browseable = "no";  # note: each home will be browseable; the "homes" share will not.
      #    "read only" = "no";
      #    "guest ok" = "no";
      #  };
      #};
    };

    avahi = {
      enable = true;
      openFirewall = true;

      publish.enable = true;
      publish.userServices = true;
    };
  };

  # To make SMB mounting easier on the command line
  environment.systemPackages = with pkgs; [
    cifs-utils
  ];
}
