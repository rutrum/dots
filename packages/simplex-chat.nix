{
  pkgs,
  system,
  ...
}: let
  version = "7.0.1";

  platforms = {
    x86_64-linux = {
      name = "simplex-chat-ubuntu-22_04-x86_64";
      hash = "sha256-OTJ583pX/3pjuSz/vVg9HYq7XqE+KPjK6nRTnXyNuR0=";
    };
    aarch64-linux = {
      name = "simplex-chat-ubuntu-22_04-aarch64";
      hash = "sha256-eYy+ALHK/NZYBHYoAKqLiJ20LX4jHP79HO7rTR6R9/Q=";
    };
  };

  platform = platforms.${system} or (throw "simplex-chat: unsupported system: ${system}");

  src = pkgs.fetchurl {
    url = "https://github.com/simplex-chat/simplex-chat/releases/download/v${version}/${platform.name}";
    hash = platform.hash;
  };
in
  pkgs.stdenv.mkDerivation {
    pname = "simplex-chat";
    inherit version src;

    nativeBuildInputs = pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      pkgs.autoPatchelfHook
    ];

    buildInputs = pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      pkgs.stdenv.cc.cc.lib
      pkgs.zlib
      pkgs.openssl
      pkgs.gmp
    ];

    dontUnpack = true;

    installPhase = ''
      install -Dm755 $src $out/bin/simplex-chat
    '';

    meta = {
      description = "Private decentralised messaging platform — CLI client";
      homepage = "https://simplex.chat";
      license = pkgs.lib.licenses.agpl3Only;
      mainProgram = "simplex-chat";
      platforms = ["x86_64-linux" "aarch64-linux"];
    };
  }
