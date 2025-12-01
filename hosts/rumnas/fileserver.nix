# https://gist.github.com/vy-let/a030c1079f09ecae4135aebf1e121ea6
{pkgs, ...}: {
  services = {
    # SFTP server
    vsftpd = {
      enable = true;
      writeEnable = true;
      localUsers = true; # local_enable=YES
      # I do not like this module

      # local_umask sets file permissions 644
      extraConfig = ''
        local_umask=0022
      '';
    };

    # SMB server
    samba = {
      enable = true;
      openFirewall = true;
      package = pkgs.samba4Full;

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
          "path" = "/mnt/raid/homes/%S";
        };
        "shared" = {
          "path" = "/mnt/raid/shared";
          "read only" = "no";
          "valid users" = "@users";
          "browseable" = "yes";
        };
        "reolink" = {
          "path" = "/mnt/raid/reolink";
          "read only" = "no";
        };
      };
    };

    # Below services are used for advertising the shares to Windows hosts
    samba-wsdd = {
      enable = true;
      openFirewall = true;
      discovery = true;
    };

    avahi = {
      enable = true;
      openFirewall = true;

      publish.enable = true;
      publish.userServices = true;
      nssmdns4 = true;
    };
  };

  environment.systemPackages = with pkgs; [
    cifs-utils # mount samba shares on cli
  ];
}
