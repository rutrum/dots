{...}: {
  virtualisation.oci-containers = {
    containers = {
      ersatztv = {
        image = "jasongdove/ersatztv:v25.1.0-nvidia";
        ports = ["8409:8409"];
        autoStart = true;
        volumes = [
          "ersatztv_config:/root/.local/share/ersatztv"
        ];
        extraOptions = [
          # docker run --rm -it --device=nvidia.com/gpu=1 ubuntu:latest nvidia-smi -L
          # GPU 0: NVIDIA GeForce RTX 2060 SUPER (UUID: <REDACTED>)
          "--device"
          "nvidia.com/gpu=1"
        ];
        environment = {
          TZ = "America/Indianapolis";
        };
      };
    };
  };
}
