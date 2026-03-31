{
  pkgs,
  system,
  ...
}: let
  version = "0.21.2";

  platforms = {
    x86_64-linux = {
      name = "agent-browser-linux-x64";
      hash = "sha256-ypVeoZvPHmAOpZSip61lyh3xOVUhFHDYKrtrs1fvgHg=";
    };
    aarch64-linux = {
      name = "agent-browser-linux-arm64";
      hash = "sha256-O3wNNHEH35mCHm1+f8q65SbXD3ABt/e/bZyi/qlQt/0=";
    };
    x86_64-darwin = {
      name = "agent-browser-darwin-x64";
      hash = "sha256-I7fM2Q+amliTqQLTzcbIA8sAfFXdNWiReWT4MJBTmpk=";
    };
    aarch64-darwin = {
      name = "agent-browser-darwin-arm64";
      hash = "sha256-rn2gnheaM2Q5EnpJ7le22IBOvrR+Kd9Aa33L+sWuZLc=";
    };
  };

  platform = platforms.${system} or (throw "Unsupported system: ${system}");

  src = pkgs.fetchurl {
    url = "https://github.com/vercel-labs/agent-browser/releases/download/v${version}/${platform.name}";
    hash = platform.hash;
  };
in
  pkgs.stdenv.mkDerivation {
    pname = "agent-browser";
    inherit version src;

    nativeBuildInputs = pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      pkgs.autoPatchelfHook
    ];

    buildInputs = pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      pkgs.stdenv.cc.cc.lib
    ];

    dontUnpack = true;

    installPhase = ''
      install -Dm755 $src $out/bin/agent-browser
    '';
  }
