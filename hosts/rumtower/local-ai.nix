{ pkgs, ... }: let
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
    local-ai = {
      image = "quay.io/go-skynet/local-ai:v3.7.0-gpu-nvidia-cuda-12";
      ports = ["8085:8080"];
      autoStart = true;
      environment = {
        
      };
      volumes = [
        "models:/models"
      ];
      extraOptions = [
        "--device"
        "nvidia.com/gpu=0"
      ];
    };
  };
}
