{pkgs, inputs, ...}: let 
  unstable-pkgs = import inputs.nixpkgs-unstable {
    system = "x86_64-linux";
  };
in {
  home.packages = with pkgs; [
    gthumb
    upscayl # ai upscaler
    krita
    unstable-pkgs.gimp3
  ];
}
