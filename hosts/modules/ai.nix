{ pkgs, config, lib, ... }:
{
  # for nixified.ai, add binary cache
  # these are from docs:
  nix.settings.trusted-substituters = ["https://ai.cachix.org"];
  nix.settings.trusted-public-keys = ["ai.cachix.org-1:N9dzRK+alWwoKXQlnn0H6aUx0lU/mspIoz8hMvGvbbc="];

  # need to figure out a way to stand these up as services
}
