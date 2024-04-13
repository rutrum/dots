{ ... }:
{
    services.adguardhome = {
        enable = true;
        openFirewall = true;
        mutableSettings = true; # change later when I know what I'm doing

        #settings = {
        #    # check this: https://github.com/AdguardTeam/AdGuardHome/wiki/Configuration#configuration-file
        #}:
    };
}
