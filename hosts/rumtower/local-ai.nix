{config, ...}: let
  secrets = config.sops.secrets;
in {
  virtualisation.oci-containers.containers.local-ai = {
    # Pin the release tag (not `latest`); keep in lockstep with
    # hosts/rumnas/local-ai.nix (P2P worker protocol). Bump to upgrade.
    image = "localai/localai:v4.12.1-gpu-nvidia-cuda-13";
    autoStart = true;
    cmd = ["worker" "p2p-llama-cpp-rpc"];
    environmentFiles = [
      "${secrets."local-ai/env".path}"
    ];
    extraOptions = [
      "--network=host"
      "--device"
      "nvidia.com/gpu=all"
    ];
  };

  sops.secrets."local-ai/env" = {};
}
