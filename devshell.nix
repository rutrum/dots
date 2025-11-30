{pkgs, ...}:
pkgs.mkShell {
  name = "dots";
  buildInputs = with pkgs; [
    sops
    alejandra

    # TODO: use nix https://github.com/cachix/git-hooks.nix
    pre-commit
  ];
}
