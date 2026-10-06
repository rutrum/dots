{config, ...}: {
  # DNS-01 credentials for the internal wildcard certificate. The values live
  # in secrets/secrets.yaml under `porkbun: { api-key, secret-key }`.
  #
  # The key must stay valid for the lifetime of the setup: renewals run ~every
  # 60 days and each one writes a fresh _acme-challenge TXT record through the
  # Porkbun API. Scope it to the rutrum.net zone rather than locking it to a
  # source IP — residential WAN addresses rotate and a stale IP allow-list
  # silently breaks renewal.
  sops.secrets."porkbun/api-key" = {};
  sops.secrets."porkbun/secret-key" = {};

  # lego reads the credentials from the environment, so render the two secrets
  # into the KEY=VALUE file that security.acme hands to the ACME service. The
  # service runs as the `acme` user, so it must own the file.
  sops.templates."porkbun-acme.env" = {
    owner = "acme";
    content = ''
      PORKBUN_API_KEY=${config.sops.placeholder."porkbun/api-key"}
      PORKBUN_SECRET_API_KEY=${config.sops.placeholder."porkbun/secret-key"}
    '';
  };

  services.caddyProxy.tls = {
    enable = true;
    domain = "internal.rutrum.net";
    email = "dave@rutrum.net";
    environmentFile = config.sops.templates."porkbun-acme.env".path;
    # For the first activation, uncomment the line below to issue against
    # Let's Encrypt staging (no rate-limit risk from a misconfig), then remove
    # it and rebuild to get a trusted production certificate:
    # server = "https://acme-staging-v02.api.letsencrypt.org/directory";
  };
}
