{ pkgs, ... }:
{
  services.syncthing = {
    settings.devices = {
      rumbeta.id = "3FRVZJQ-RG6QI2E-B2WIQ4W-7MIJ2LB-ZCHLSI4-WQVTTUS-SRFAOUS-JUAEVAI";
      rumprism.id = "RVLPXSV-2XJT3ZJ-LNTRNRB-XQWY372-EPLFFPB-Z74FVM6-SVIYHRF-6777ZQ6";
    };
  };
}
