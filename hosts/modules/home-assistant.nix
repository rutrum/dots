{ pkgs, config, ... }:
{
# TODO: not finished, needs testing
  virtualisation.oci-containers.containers = {
    home-assistant = {
      image = "ghcr.io/home-assistant/home-assistant:stable";
      ports = [ "8082:8123" "1400:1400" ];
      volumes = [
        # "/somewhere:/config"
        "/etc/localhost:/etc/localtime:ro"
      ];
      environment = {
        TZ = "America/Chicago";
      };
      dependsOn = [];
      autoStart = true;
    };
    home-assistant-zwave-js = {
      image = "kpine/zwave-js-server:latest";
      # ports = [ "8083:3000" ]; # shouldn't be necessary, only home-assistant needs this
      #? devices = "";
      environment = {
        S2_ACCESS_CONTROL_KEY = "7764841BC794A54442E324682A550CEF";
        S2_AUTHENTICATED_KEY = "66EA86F088FFD6D7497E0B32BC0C8B99";
        S2_UNAUTHENTICATED_KEY = "2FAB1A27E19AE9C7CC6D18ACEB90C357";
        S0_LEGACY_KEY = "17DFB0C1BED4CABFF54E4B5375E257B3";
      };
    };
  };
}
