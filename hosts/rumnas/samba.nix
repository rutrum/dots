# https://gist.github.com/vy-let/a030c1079f09ecae4135aebf1e121ea6
{ pkgs, ... }:
{
  services = {
    samba = {
      enable = true;
      openFirewall = true;
      package = pkgs.samba4Full;

      # You will still need to set up the user accounts to begin with:
      # $ sudo smbpasswd -a yourusername

      # wait until 24.11
      settings = {
        global = {
          security = "user";
          "workgroup" = "WORKGROUP";
          "map to guest" = "Bad User";
          "browseable" = "yes";
        };
        homes = {
          "read only" = "no";
          "inherit acls" = "yes";
          "valid users" = "%S";
          "path" = "/mnt/vault/home/%S";
        };
        "public" = {
          "path" = "/mnt/vault/public";
          "read only" = "no";
          "guest ok" = "yes";
        };
      };
    };


    # Below services are used for advertising the shares to Windows hosts
    samba-wsdd = {
      enable = true;
      openFirewall = true;
    };

    avahi = {
      enable = true;
      openFirewall = true;

      publish.enable = true;
      publish.userServices = true;
    };
  };

  environment.systemPackages = with pkgs; [
    cifs-utils # mount samba shares on cli
  ];
}
