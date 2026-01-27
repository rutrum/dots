{
  pkgs,
  config,
  inputs,
  ...
}: {
  services.caddyProxy.services.hass.port = 8082;

  systemd.services = inputs.self.lib.mkPodmanNetwork config "home-assistant";

  virtualisation.oci-containers.containers = {
    home-assistant = {
      image = "ghcr.io/home-assistant/home-assistant:2025.5";
      ports = ["8082:8123" "1400:1400"];
      volumes = [
        "/root/volumes/home-assistant/config:/config"
        "/etc/localtime:/etc/localtime:ro"
      ];
      # doens't feel necessary when /localtime is mapped
      #environment = {
      #  TZ = "America/Chicago";
      #};
      autoStart = true;
      extraOptions = [
        # not working
        #"--device=/dev/serial/by-id/usb-Silicon_Labs_HubZ_Smart_Home_Controller_6160054B-if00-port0"
        #"--device=/dev/serial/by-id/usb-Silicon_Labs_HubZ_Smart_Home_Controller_6160054B-if01-port0"
        "--privileged" # try this instead
      ];
      networks = ["home-assistant"];
    };
    zwave-js = {
      image = "kpine/zwave-js-server:1.40.2-14.3.6-35e28517";
      # ports = [ "8083:3000" ]; # shouldn't be necessary, only home-assistant needs this
      environment = {
        S2_ACCESS_CONTROL_KEY = "7764841BC794A54442E324682A550CEF";
        S2_AUTHENTICATED_KEY = "66EA86F088FFD6D7497E0B32BC0C8B99";
        S2_UNAUTHENTICATED_KEY = "2FAB1A27E19AE9C7CC6D18ACEB90C357";
        S0_LEGACY_KEY = "17DFB0C1BED4CABFF54E4B5375E257B3";
      };
      extraOptions = [
        # Find the device for the hub and map it.  Previous config mapped to symlink:
        # HubZ -> /dev/serial/by-path/platform-fd500000.pcie-pci-0000:01:00.0-usb-0:1.2:1.0-port0
        #"--device=/home/rutrum/HubZ:/dev/zwave"
        "--device=/dev/serial/by-id/usb-Silicon_Labs_HubZ_Smart_Home_Controller_6160054B-if00-port0:/dev/zwave"
      ];
      networks = ["home-assistant"];
    };
  };
}
