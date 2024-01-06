{ firefox-addons, pkgs-stable }:
{
  enable = true;
  package = pkgs-stable.firefox;

  profiles.normal = {
    name = "normal";
    isDefault = true;
    extensions = with firefox-addons; [
      bitwarden
      ublock-origin
      sponsorblock
      floccus
    ];
    # referenced https://brainfucksec.github.io/firefox-hardening-guide
    settings = {
      # new tab page
      "browser.start.page" = 0; # blank
      # "browser.newtagpage..." do if using newtab page

      # geolocation
      "geo.provider.use_gpsd" = false;
      "geo.provider.use_geoclue" = false;
      
      # locale
      "intl.accept_languages" = "en-US, en";

      # updates
      "app.update.auto" = false;

      # addon recommendations
      "extensions.getAddons.showPane" = false;
      "extensions.htmlaboutaddons.recommendations.enabled" = false;
      "browser.discovery.enabled" = false;

      # telemetry
      "toolkit.coverage.opt-out" = true;
      "beacon.enabled" = false;
      # there's many more, see article

      # suggestions, autofill
      "browser.search.suggest.enabled" = false;
      "browser.urlbar.suggest.searches" = false;
      # reconsider the above if history not suggested
      "browser.formfill.enable" = false;
      # and more

      # passwords
      "signon.rememberSignons" = false;
      "signon.autofillForms" = false;
      "signon.formlessCapture.enabled" = false;

      # HTTPS
      "dom.security.https_only_mode" = true;
      "dom.security.https_only_mode_send_http_background_request" = false;

      # prompt for download
      "browser.download.useDownloadDir" = false;

      # disable extensions
      "extensions.pocket.enabled" = false;
      "extensions.Screenshots.disabled" = true;

      # webgl doesn't work, force it?
      # "webgl.force-enabled" = true;
    };
    search = {
      default = "DuckDuckGo";
      force = true;

      engines = {
        "Nix Packages" = {
          urls = [{
            template = "https://search.nixos.org/packages";
            params = [
              { name = "type"; value = "packages"; }
              { name = "query"; value = "{searchTerms}"; }
            ];
          }];
          # icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
          definedAliases = [ "np" ];
        };
        "Home Manager Options" = {
          urls = [{
            template = "https://mipmip.github.io/home-manager-option-search/";
            params = [
              { name = "query"; value = "{searchTerms}"; }
            ];
          }];
          definedAliases = [ "hm" ];
        };
        "YouTube" = {
          urls = [{
            template = "https://www.youtube.com/results";
            params = [
              { name = "search_query"; value = "{searchTerms}"; }
            ];
          }];
          definedAliases = [ "yt" ];
        };

        "Bing".metaData.hidden = true;
        "Google".metaData.hidden = true;
      };
    };
  };
}
