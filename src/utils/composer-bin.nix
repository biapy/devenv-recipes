{ config, ... }:
let
  working-dir = "${config.env.DEVENV_ROOT}";
  composer-bin = "${config.languages.php.packages.composer}/bin/composer";
in
{
  installTask = name: namespace: {
    description = "Install ${name}";
    before = [
      "devenv:enterShell"

    ];
    after = [
      "devenv-recipes:enterShell:initialize:composer-bin"
      "devenv-recipes:enterShell:initialize:${namespace}"
      "devenv-recipes:enterShell:install:composer"
    ];
    exec = ''
      set -o 'errexit'
      cd '${working-dir}'
      '${composer-bin}' 'bin' '${namespace}' 'install'
    '';
  };
}
