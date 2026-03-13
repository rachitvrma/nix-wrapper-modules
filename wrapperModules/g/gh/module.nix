{
  wlib,
  lib,
  pkgs,
  config,
  ...
}:
let
  yamlFormat = pkgs.formats.yaml { };
  inherit (lib) mkOption;
in
{
  options = {
    settings = mkOption {
      inherit (yamlFormat) type;
      default = { };
      description = ''
        Configuration that goes to {file}`config.yml`
      '';
    };
  };
  config = {
    package = lib.mkDefault pkgs.gh;
    drv = {
      configYml = yamlFormat.generate "config.yml" config.settings;
      passAsFile = [
        "configYml"
      ];
      buildPhase = ''
        runHook preBuild
        mkdir -p "${placeholder config.outputName}/gh-config"
        cp "$(cat "$configYmlPath")" "${placeholder config.outputName}/gh-config/config.yml"
        runHook postBuild
      '';
      env = {
        GH_CONFIG_DIR = "${placeholder config.outputName}/gh-config";
      };
    };
    meta.maintainers = [ wlib.maintainers.rachitvrma ];
  };
}
