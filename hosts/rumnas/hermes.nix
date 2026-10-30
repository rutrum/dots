{
  config,
  lib,
  pkgs,
  flake,
  inputs,
  ...
}: let
  hermes-base = inputs.hermes-agent.packages.${pkgs.system}.default;
in {
  imports = [
    inputs.hermes-agent.nixosModules.default
    inputs.hermes-webui.nixosModules.default
    inputs.self.nixosModules.simplex-chat
  ];

  services.hermes-agent = {
    enable = true;
    package = hermes-base;

    settings = {
      providers.litellm = {
        base_url = "http://litellm.rum.internal/v1";
        key_env = "LITELLM_API_KEY";
        # Pin Hermes to the RTX 4070 instance on rumtower (128K, all-GPU,
        # ~105 tok/s) rather than the fleet default that rumnas served.
        default_model = "rumtower/gemma-4-12b-it-qat-q4_0";
      };
      model = {
        provider = "custom:litellm";
        default = "rumtower/gemma-4-12b-it-qat-q4_0";
        context_length = 128000;
      };
      # The compression summariser defaults to the main model, but a stale
      # context_length hint would clamp compaction to the old window (Hermes
      # lowers the trigger to the aux window; see conversation_compression.py).
      # Keep this in step with model.context_length above.
      auxiliary.compression.context_length = 128000;
      terminal.backend = "local";
      toolsets = ["all"];

      # --- Token budget (hermes-optimization-guide ch. 05) ---
      # Global toolset suppression; applied last, on every surface. `browser`
      # also removes `browser-use`. `delegation` is deliberately kept for
      # subagents.
      agent.disabled_toolsets = [
        "tts"
        "browser"
        "code_execution"
        "connections"
      ];

      # Cap what tools may dump into the context (defaults target 128K+ models).
      tool_output = {
        max_bytes = 25000;
        max_lines = 1000;
      };
      file_read_max_chars = 50000;
      web.extract_char_limit = 8000;

      # Keep the last few real instructions verbatim through compaction.
      compression.min_tail_user_messages = 3;

      # --- Skills (hermes-optimization-guide ch. 08) ---
      # Each enabled skill adds a ~19-token line to every call's index, whether
      # or not it is used (bodies load lazily). `hermes curator usage` shows
      # only add-mealie-recipe and hermes-agent had ever fired, so keep a small
      # stack-relevant set and disable the rest. The kept 19 are intentionally
      # absent from this list: add-mealie-recipe, hermes-agent,
      # local-ai-interaction, llama-cpp, serving-llms-vllm, messaging-gateways,
      # youtube-content, ocr-and-documents, pdf, openhue, systematic-debugging,
      # python-debugpy, hermes-agent-skill-authoring, github-repo-management,
      # github-pr-workflow, github-issues, arxiv, llm-wiki, obsidian.
      skills.disabled = [
        "airtable"
        "apple-notes"
        "apple-reminders"
        "architecture-diagram"
        "ascii-art"
        "ascii-video"
        "baoyu-infographic"
        "blocked-page-recovery"
        "blogwatcher"
        "box"
        "claude-code"
        "claude-design"
        "codebase-inspection"
        "codex"
        "comfyui"
        "competitor-news-monitor"
        "computer-use"
        "design-md"
        "document-to-action-items"
        "docx"
        "dogfood"
        "email-inbox-triage"
        "evaluating-llms-harness"
        "excalidraw"
        "findmy"
        "gif-search"
        "github"
        "github-auth"
        "github-code-review"
        "google-workspace"
        "grounded-citations"
        "himalaya"
        "huggingface-hub"
        "humanizer"
        "imessage"
        "inspecting-hermes-desktop-dom"
        "manim-video"
        "maps"
        "meeting-action-items"
        "nano-pdf"
        "node-inspect-debugger"
        "notion"
        "opencode"
        "p5js"
        "plan"
        "polymarket"
        "popular-web-designs"
        "powerpoint"
        "pretext"
        "product-price-monitor"
        "requesting-code-review"
        "research-paper-writing"
        "simplify-code"
        "sketch"
        "songsee"
        "songwriting-and-ai-music"
        "spike"
        "teams-meeting-pipeline"
        "test-driven-development"
        "touchdesigner-mcp"
        "weekly-review-planning"
        "weights-and-biases"
        "xlsx"
        "xurl"
      ];

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

  # Browser UI for the same agent. Runs as the hermes user so it can read the
  # agent's HERMES_HOME (/var/lib/hermes/.hermes) and reuse its venv/state.
  services.hermes-webui = {
    enable = true;
    user = "hermes";
    group = "hermes";
    host = "127.0.0.1";
    port = 8787;
    hermesHome = "${config.services.hermes-agent.stateDir}/.hermes";
    agent = {
      # hermes-agent exposes passthru.hermesVenv (-> HERMES_WEBUI_PYTHON) but
      # not passthru.hermesAgentDir, so point the WebUI at the agent source tree.
      package = hermes-base;
      dir = "${hermes-base}/share/hermes-agent";
    };
  };

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
