{...}: {
  # Create a systemd service that creates a podman network if it doesn't exist.
  # Usage: systemd.services = inputs.self.lib.mkPodmanNetwork config "networkname";
  mkPodmanNetwork = config: name: {
    "init-${name}-network" = {
      description = "Create podman network for ${name} containers.";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig.Type = "oneshot";
      script = let
        podmancli = "${config.virtualisation.podman.package}/bin/podman";
      in ''
        check=$(${podmancli} network ls | grep "${name}" || true)
        if [ -z "$check" ]; then
          ${podmancli} network create ${name}
        else
          echo "Network '${name}' already exists."
        fi
      '';
    };
  };
}
