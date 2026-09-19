{perSystem, ...}: {
  # openFirewall removed: Caddy-only, reached via paperless.rum.internal

  services.paperless = {
    enable = true;
    package = perSystem.nixpkgs-unstable.paperless-ngx;
    address = "0.0.0.0";
    port = 8000;
    dataDir = "/mnt/raid/services/paperless";
    settings = {
      PAPERLESS_OCR_USER_ARGS = ''{"invalidate_digital_signatures": true}'';

      # --- AI / RAG semantic search via LocalAI ---
      # LocalAI (localai.rum.internal:8089) serves both an OpenAI-compatible
      # chat/LLM channel and embeddings channel from the same /v1 base URL.
      PAPERLESS_AI_ENABLED = true;
      PAPERLESS_AI_LLM_BACKEND = "openai-like";
      PAPERLESS_AI_LLM_ENDPOINT = "http://local-ai.rum.internal/v1";
      PAPERLESS_AI_LLM_API_KEY = "local-ai-dummy-key"; # LocalAI ignores this
      PAPERLESS_AI_LLM_MODEL = "gemma-4-12b-it-qat-q4_0"; # existing LLM for RAG answers
      # Embeddings for semantic search
      PAPERLESS_AI_LLM_EMBEDDING_BACKEND = "openai-like";
      PAPERLESS_AI_LLM_EMBEDDING_MODEL = "nemotron-3-embed-1b-q4";
      PAPERLESS_AI_LLM_EMBEDDING_ENDPOINT = "http://local-ai.rum.internal/v1";
    };
  };
}
