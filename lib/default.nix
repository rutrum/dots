{
  flake,
  inputs,
}: {
  mkPodmanNetwork = name: {
    "init-${name}-network" = {
      description = "Create network for ${name} containers.";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig.type = "oneshot";
      script = let
        dockercli = "${config.virtualisation.podman.package}/bin/podman";
      in ''
        check=$(${dockercli} network ls | grep "${name}" || true)
        if [ -z "$check" ]; then
          ${dockercli} network create ${name}
        else
          echo "Network '${name}' already exists."
        fi
      '';
    };
  };
}
