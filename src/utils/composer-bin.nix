{ config, ... }:
let
  tasks = import ./tasks.nix { inherit config; };
  working-dir = "${config.env.DEVENV_ROOT}";
  composer-binary = "${config.languages.php.packages.composer}/bin/composer";
in
{

  initializeComposerJsonTask =
    {
      name,
      namespace,
      composerJsonPath,
    }:
    {
      "devenv-recipes:enterShell:initialize:composer-bin:${namespace}:composer.json" = {
        description = "Initialize ${name} composer.json";
        before = [ "devenv:enterShell" ];
        exec = tasks.initializeFile "vendor-bin/${namespace}/composer.json" composerJsonPath;
      };
    };

  initializeConfigFileTask =
    {
      name,
      namespace,
      configFile,
      configFilePath,
    }:
    {
      "devenv-recipes:enterShell:initialize:composer-bin:${namespace}:configuration" = {
        description = ''Initialize ${name} "${configFile}" configuration file'';
        before = [ "devenv:enterShell" ];
        exec = tasks.initializeFile configFile configFilePath;
      };
    };

  installTask =
    { name, namespace }:
    {
      "devenv-recipes:enterShell:install:composer-bin:${namespace}" = {
        description = "Install ${name}";
        before = [
          "devenv:enterShell"

        ];
        after = [
          "devenv-recipes:enterShell:initialize:composer-bin"
          "devenv-recipes:enterShell:initialize:composer-bin:${namespace}:composer.json"
          "devenv-recipes:enterShell:install:composer"
        ];
        exec = ''
          set -o 'errexit'
          cd '${working-dir}'
          '${composer-binary}' 'bin' '${namespace}' 'install'
        '';
      };
    };
}
