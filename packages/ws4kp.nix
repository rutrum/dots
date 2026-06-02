{pkgs, ...}:
pkgs.buildNpmPackage {
  pname = "ws4kp";
  version = "6.5.9";

  src = pkgs.fetchFromGitHub {
    owner = "netbymatt";
    repo = "ws4kp";
    rev = "v6.5.9";
    hash = "sha256-nI0akYjQx8QzMiCsep14W2VfTiHRUiq8VKsP8ZEk5/w=";
  };

  npmDepsHash = "sha256-f+WPr0CnFxElx1A7YyJgDkb7huqQo0ib5R8KeGKc1z4=";

  # Server mode runs directly from source — no gulp/webpack build needed
  dontNpmBuild = true;

  nativeBuildInputs = [pkgs.makeWrapper];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/ws4kp $out/bin

    cp -r server datagenerators proxy src views index.mjs package.json node_modules \
      $out/lib/ws4kp/

    # The app reads data files with relative paths, so pin the working directory
    makeWrapper ${pkgs.nodejs}/bin/node $out/bin/ws4kp \
      --run "cd '$out/lib/ws4kp'" \
      --add-flags "$out/lib/ws4kp/index.mjs"

    runHook postInstall
  '';

  meta = {
    description = "Web-based recreation of the WeatherStar 4000 (90s Weather Channel)";
    homepage = "https://github.com/netbymatt/ws4kp";
    license = pkgs.lib.licenses.mit;
    mainProgram = "ws4kp";
  };
}
