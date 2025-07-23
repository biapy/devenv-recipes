{ config, ... }:
let
  working-dir = "${config.env.DEVENV_ROOT}";
  composer-binary = "${config.languages.php.packages.composer}/bin/composer";
in
{
  installTask = name: namespace: {
    description = "Install ${name}";
    before = [
      "devenv:enterShell"

    ];
    after = [
      "devenv-recipes:enterShell:initialize:composer-bin"
      "devenv-recipes:enterShell:initialize:composer-bin:${namespace}"
      "devenv-recipes:enterShell:install:composer"
    ];
    exec = ''
      set -o 'errexit'
      cd '${working-dir}'
      '${composer-binary}' 'bin' '${namespace}' 'install'
    '';
  };
}
