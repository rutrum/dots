{
  config,
  lib,
  pkgs,
  ...
}: let
  secrets = config.sops.secrets;
in {
  # LiteLLM — OpenAI-compatible LLM gateway/proxy.
  # Sits in front of local-ai (and optionally cloud providers) so consumers
  # (hermes, mealie, custom apps) can use one endpoint with routing, fallbacks
  # and spend tracking.
  services.litellm = {
    enable = true;
    host = "127.0.0.1"; # Caddy-only (firewall is locked down anyway)
    port = 4000;
    environmentFile = secrets."litellm/env".path;

    settings = {
      # Public model name -> backend. Clients request the model_name below.
      model_list = [
        {
          model_name = "gemma-4-12b-it-qat-q4_0";
          litellm_params = {
            model = "openai/gemma-4-12b-it-qat-q4_0";
            api_base = "http://local-ai.rum.internal:8089/v1";
            api_key = "local-ai-dummy-key"; # local-ai does not authenticate
          };
        }
        {
          # Winnow-E4B — Gemma 4 E4B fine-tune for typed decisions, served by
          # the rumnas GPUs. Small, fast, classification/decision-shaped work.
          model_name = "winnow-e4b";
          litellm_params = {
            model = "openai/winnow-e4b";
            api_base = "http://local-ai.rum.internal:8089/v1";
            api_key = "local-ai-dummy-key"; # local-ai does not authenticate
          };
        }
        {
          # rumtower's RTX 4070 instance of Gemma 4 12B (128K single-slot
          # context, all-GPU, ~105 tok/s). Same weights as the fleet default
          # above, but pinned to the tower and *discoverable* (the rumtower/*
          # wildcard below is hidden). Ask for it by this full name to route
          # work to the 4070; the bare name still goes to rumnas.
          model_name = "rumtower/gemma-4-12b-it-qat-q4_0";
          litellm_params = {
            model = "openai/gemma-4-12b-it-qat-q4_0";
            api_base = "http://rumtower.local-ai.rum.internal:8089/v1";
            api_key = "local-ai-dummy-key"; # local-ai does not authenticate
          };
        }
        {
          # Everything the rumtower LocalAI serves. Ask for it as
          # "rumtower/<model>" (e.g. "rumtower/qwen3.5-9b-dflash"); LiteLLM
          # strips the "rumtower/" prefix before the upstream call, so a model
          # added in rumtower's WebUI works with no config change here.
          # LiteLLM sorts wildcards by specificity, so this wins over "*".
          model_name = "rumtower/*";
          litellm_params = {
            model = "openai/*";
            api_base = "http://rumtower.local-ai.rum.internal:8089/v1";
            api_key = "local-ai-dummy-key"; # local-ai does not authenticate
          };
          model_info = {
            discoverable = false;
          };
        }
        {
          model_name = "openrouter/*";
          litellm_params = {
            model = "openrouter/*"; # enable them all
            api_key = "os.environ/OPENROUTER_API_KEY";
          };
          # Don't advertise the literal wildcard in /v1/models (clients' model
          # pickers see only the real entries). Requests by name still route.
          model_info = {
            discoverable = false;
          };
        }
        {
          # Catch-all: any model name not matched above (e.g. what pi's built-in
          # openrouter catalog sends) routes to OpenRouter as-is. Lets pi's full
          # built-in catalog work through the gateway. See docs/llm-stack.md.
          model_name = "*";
          litellm_params = {
            model = "openrouter/*";
            api_key = "os.environ/OPENROUTER_API_KEY";
          };
          model_info = {
            discoverable = false;
          };
        }
      ];

      general_settings = {
        # Required to authenticate /chat/completions against the proxy
        master_key = "os.environ/MASTER_KEY";
      };

      # Drop parameters the upstream provider doesn't support (e.g. pi sends
      # reasoning_effort, which local-ai's OpenAI-compatible API rejects).
      litellm_settings = {
        drop_params = true;
      };

      # Langfuse tracing is deferred
      # When Langfuse is up, enable one of:
      #   legacy:  callbacks = ["langfuse"]  (env: LANGFUSE_PUBLIC_KEY/SECRET_KEY/HOST)
      #   otel v2: callbacks = ["otel"]      (env: OTEL_EXPORTER=otlp_http, OTEL_OTLP_ENDPOINT=...)
      # litellm_settings = {
      #   callbacks = ["langfuse"];
      # };
    };
  };

  # Subdomain: http://litellm.rum.internal (Caddy reverse proxy)
  services.caddyProxy.services.litellm.port = 4000;

  sops.secrets."litellm/env" = {
    restartUnits = ["litellm.service"];
  };
}
