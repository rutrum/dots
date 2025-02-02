{
  config,
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    inputs.cura.packages.x86_64-linux.default
    #cura #broken for now
    # look out for this: https://github.com/NixOS/nixpkgs/pull/367409
  ];
  services.flatpak.packages = [
    "flathub-beta:app/org.openscad.OpenSCAD//beta"
  ];
}
