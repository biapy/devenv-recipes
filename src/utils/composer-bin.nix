{ config, ... }:
let
  tasks = import ./tasks.nix { inherit config; };
  composerCommand = "${config.languages.php.packages.composer}/bin/composer";
in
{

  initializeComposerJsonTask =
    {
      name,
      namespace,
      composerJsonPath,
      ...
    }:
    {
      "devenv-recipes:enterShell:initialize:composer-bin:${namespace}:composer-json" = {
        description = "Initialize ${name} composer.json";
        before = [ "devenv:enterShell" ];
        exec = tasks.initializeFile "vendor-bin/${namespace}/composer.json" composerJsonPath;
      };
    };

  initializeConfigFilesTask =
    {
      name,
      namespace,
      configFiles,
      ...
    }:
    {
      "devenv-recipes:enterShell:initialize:composer-bin:${namespace}:configuration" = {
        description = ''Initialize ${name} configuration file(s)'';
        before = [ "devenv:enterShell" ];
        exec = tasks.initializeFiles configFiles;
      };
    };

  installTask =
    { name, namespace, ... }:
    {
      "devenv-recipes:enterShell:install:composer-bin:${namespace}" = {
        description = "Install ${name}";
        before = [
          "devenv:enterShell"

        ];
        after = [
          "devenv-recipes:enterShell:initialize:composer-bin"
          "devenv-recipes:enterShell:initialize:composer-bin:${namespace}:composer-json"
          "devenv-recipes:enterShell:install:composer"
        ];
        # Use the composer command to install the too

        exec = ''
          set -o 'errexit'
          cd "''${DEVENV_ROOT}"
          '${composerCommand}' 'bin' '${namespace}' 'install'
        '';
      };
    };
}
