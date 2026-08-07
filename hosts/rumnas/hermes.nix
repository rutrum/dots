{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [inputs.hermes-agent.nixosModules.default];

  services.hermes-agent = {
    enable = true;

    settings = {
      model = {
        provider = "custom";
        default = "gemma-4-12b-it-qat-q4_0";
        base_url = "http://local-ai.rum.internal:8089/v1";
        context_length = 64000;
      };
      terminal.backend = "local";
      toolsets = ["all"];
      # Enable the gateway's OpenAI-compatible API server on localhost
      gateway.api_server = {
        enabled = true;
        host = "127.0.0.1";
        port = 8642;
      };
    };

    addToSystemPackages = true;
  };

  # Hermes web dashboard (separate from the gateway service)
  systemd.services.hermes-dashboard = {
    description = "Hermes Agent Web Dashboard";
    after = ["hermes-agent.service" "network.target"];
    wants = ["hermes-agent.service"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "simple";
      User = "hermes";
      ExecStart = "${lib.getExe config.services.hermes-agent.package} dashboard --port 9119";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
