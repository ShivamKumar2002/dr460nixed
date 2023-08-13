{ config
, lib
, pkgs
, spicetify-nix
, ...
}:
with lib;
let
  cfg = config.dr460nixed.desktops;
  spicePkgs = spicetify-nix.packages.${pkgs.system}.default;
in
{
  options.dr460nixed.desktops = {
    enable = mkOption
      {
        default = false;
        type = types.bool;
        description = mdDoc ''
          Whether to enable basic dr460nized desktop theming.
        '';
      };
  };

  config = mkIf cfg.enable {
    # Currently needed to obtain nightly Rustdesk
    services.flatpak.enable = true;

    # Additional KDE packages not included by default
    environment.systemPackages = with pkgs; [ jamesdsp ];

    # Define the default fonts Fira Sans & Jetbrains Mono Nerd Fonts
    fonts.enableDefaultPackages = false;

    # Fix "the name ca.desrt.dconf was not provided by any .service files"
    # https://nix-community.github.io/home-manager/index.html
    programs.dconf.enable = true;

    # # Kernel paramters & settings
    boot.kernelParams = [ "mitigations=off" ];

    # Fancy themed, enhanced Spotify
    programs.spicetify = {
      enable = true;
      theme = spicePkgs.themes.Comfy;
      enabledExtensions = with spicePkgs.extensions; [
        autoSkipVideo
        bookmark
        fullAlbumDate
        fullAppDisplayMod
        genre
        groupSession
        hidePodcasts
        history
        playlistIcons
        popupLyrics
        seekSong
        songStats
      ];
      injectCss = true;
      replaceColors = true;
      overwriteAssets = true;
      sidebarConfig = true;
      enabledCustomApps = with spicePkgs.apps; [
        lyrics-plus
        new-releases
      ];
    };
  };
}
