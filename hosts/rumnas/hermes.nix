{
  config,
  lib,
  pkgs,
  flake,
  inputs,
  ...
}: let
  hermes-base = inputs.hermes-agent.packages.${pkgs.system}.default;

  patched-adapter = pkgs.runCommand "patched-simplex-adapter" {} ''
    mkdir -p $out/share/hermes-agent/plugins/platforms/simplex
    cat ${hermes-base}/share/hermes-agent/plugins/platforms/simplex/adapter.py \
      | ${pkgs.python3}/bin/python3 ${../../packages/patch-simplex-adapter.py} \
      > $out/share/hermes-agent/plugins/platforms/simplex/adapter.py
    cp ${hermes-base}/share/hermes-agent/plugins/platforms/simplex/__init__.py \
       $out/share/hermes-agent/plugins/platforms/simplex/__init__.py
    cp ${hermes-base}/share/hermes-agent/plugins/platforms/simplex/plugin.yaml \
       $out/share/hermes-agent/plugins/platforms/simplex/plugin.yaml
  '';
in {
  imports = [
    inputs.hermes-agent.nixosModules.default
    inputs.self.nixosModules.simplex-chat
  ];

  services.hermes-agent = {
    enable = true;
    package = hermes-base;

    settings = {
      model = {
        provider = "custom";
        default = "gemma-4-12b-it-qat-q4_0";
        base_url = "http://litellm.rum.internal/v1";
        key_env = "LITELLM_API_KEY";
        context_length = 64000;
      };
      terminal.backend = "local";
      toolsets = ["all"];
      gateway.api_server = {
        enabled = true;
        host = "127.0.0.1";
        port = 8642;
      };
    };

    environment = {
      SIMPLEX_WS_URL = "ws://127.0.0.1:5225";
      SIMPLEX_ALLOWED_USERS = "StirringZaniness";
      SIMPLEX_HOME_CHANNEL = "StirringZaniness";
    };

    environmentFiles = [config.sops.secrets."hermes/env".path];

    extraPackages = [flake.packages.${pkgs.system}.simplex-chat pkgs.uv];

    addToSystemPackages = true;
  };

  systemd.services.hermes-agent = {
    serviceConfig.BindReadOnlyPaths = [
      "${patched-adapter}/share/hermes-agent/plugins/platforms/simplex/adapter.py:${hermes-base}/share/hermes-agent/plugins/platforms/simplex/adapter.py"
    ];
  };

  services.simplex-chat = {
    enable = true;
    user = "hermes";
    group = "hermes";
    dataDir = "/var/lib/hermes/.simplex";
  };

  sops.secrets."hermes/env" = {
    owner = "hermes";
    restartUnits = ["hermes-agent.service"];
  };

  environment.systemPackages = [flake.packages.${pkgs.system}.simplex-chat];

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
