{
  pkgs,
  config,
  ...
}: {
  systemd.services.init-linkwarden-network = {
    description = "Create network for linkwarden containers.";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];

    serviceConfig.type = "oneshot";
    script = let
      podman = "${config.virtualisation.podman.package}/bin/podman";
    in ''
      check=$(${podman} network ls | grep "linkwarden" || true)
      if [ -z "$check" ]; then
        ${podman} network create linkwarden
      else
        echo "Network 'linkwarden' already exists."
      fi
    '';
  };
  virtualisation.oci-containers.containers = let 
    POSTGRES_PASSWORD="CUSTOM_POSTGRES_PASSWORD";
    environment = {
      inherit POSTGRES_PASSWORD;
      NEXTAUTH_URL="http://rumnas.lynx-chromatic.ts.net:8088/api/v1/auth";
      NEXTAUTH_SECRET="VERY_SENSITIVE_SECRET";
      MEILI_MASTER_KEY="VERY_SENSITIVE_MEILI_MASTER_KEY";
      DATABASE_URL="postgresql://postgres:${POSTGRES_PASSWORD}@linkwarden-db:5432/postgres";
      MEILI_HOST="linkwarden-search:7700";
    };
  in {
    linkwarden = {
      inherit environment;
      image = "ghcr.io/linkwarden/linkwarden:v2.11.5";
      autoStart = true;
      ports = ["8088:3000"];
      volumes = [
        "linkwarden-data:/data/data"
      ];
      dependsOn = [ "linkwarden-db" "linkwarden-search" ];
      extraOptions = [
        "--network=linkwarden"
      ];
    };
    linkwarden-db = {
      inherit environment;
      image = "library/postgres:16";
      volumes = [
        "linkwarden-db:/var/lib/postgresql/data"
      ];
      extraOptions = [
        "--network=linkwarden"
      ];
    };
    linkwarden-search = {
      inherit environment;
      image = "getmeili/meilisearch:v1.12.8";
      volumes = [ "linkwarden-search:/meili_data" ];
      extraOptions = [
        "--network=linkwarden"
      ];
    };
  };
}
