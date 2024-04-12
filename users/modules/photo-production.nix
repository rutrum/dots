{ pkgs, ... }:
{
    home.packages = with pkgs; [
        gimp
        upscayl # ai upscaler
    ];
}
