{ pkgs, config, ... }: let
  llama-swap-config = pkgs.writeText "llama-swap-config.yaml" ''
    healthCheckTimeout: 300
    logRequests: true
    models:
      "qwen2.5-dyanka-7b":
        proxy: "http://127.0.0.1:9999"
        cmd: >
          /app/llama-server
          -hf tensorblock/Qwen2.5-Dyanka-7B-Preview-GGUF
          --port 9999

      "qwen2.5":
        proxy: "http://127.0.0.1:9999"
        cmd: >
          /app/llama-server
          -hf bartowski/Qwen2.5-0.5B-Instruct-GGUF:Q4_K_M
          --port 9999

      "smollm2":
        proxy: "http://127.0.0.1:9999"
        cmd: >
          /app/llama-server
          -hf bartowski/SmolLM2-135M-Instruct-GGUF:Q4_K_M
          --port 9999
  '';
in {
  virtualisation.oci-containers.containers = {
    llama-swap = {
      image = "ghcr.io/mostlygeek/llama-swap:cuda";
      ports = ["9292:8080"];
      autoStart = true;

      # mount config to container
      volumes = [
        "${llama-swap-config}:/app/config.yaml"
        "model-cache:/root/.cache/llama.cpp"
      ];
      extraOptions = [
        # docker run --rm -it --device=nvidia.com/gpu=1 ubuntu:latest nvidia-smi -L
        # GPU 0: NVIDIA GeForce RTX 2060 SUPER (UUID: <REDACTED>)
        "--device"
        "nvidia.com/gpu=0"
      ];
    };
  };
}
