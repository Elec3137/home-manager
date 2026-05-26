{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.foot;
  iniFormat = pkgs.formats.ini { listsAsDuplicateKeys = true; };
in
{
  meta.maintainers = with lib.maintainers; [ plabadens ];

  options.programs.foot = {
    enable = lib.mkEnableOption "Foot terminal";

    package = lib.mkPackageOption pkgs "foot" { };

    server.enable = lib.mkEnableOption "Foot terminal server";

    settings = lib.mkOption {
      inherit (iniFormat) type;
      default = { };
      description = ''
        Configuration written to
        {file}`$XDG_CONFIG_HOME/foot/foot.ini`. See <https://codeberg.org/dnkl/foot/src/branch/master/foot.ini>
        for a list of available options.
      '';
      example = {
        main = {
          term = "xterm-256color";

          font = "Fira Code:size=11";
          dpi-aware = "yes";
        };

        mouse = {
          hide-when-typing = "yes";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      (lib.hm.assertions.assertPlatform "programs.foot" pkgs lib.platforms.linux)
    ];

    home.packages = [ cfg.package ];

    xdg.configFile."foot/foot.ini" = lib.mkIf (cfg.settings != { }) {
      source = iniFormat.generate "foot.ini" cfg.settings;
    };

    xdg.autostart = lib.mkIf cfg.server.enable {
      enable = true;
      entries = [
        "${config.programs.foot.package}/share/applications/foot-server.desktop"
      ];
    };
  };
}
