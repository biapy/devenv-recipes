# Install bamarni/composer-bin-plugin
# @see https://github.com/bamarni/composer-bin-plugin
{ config, ... }:
let
  composer-json = "${config.env.DEVENV_ROOT}/composer.json";
  composer-bin = "${config.languages.php.packages.composer}/bin/composer";
in
{
  imports = [ ./composer.nix ];

  # https://devenv.sh/tasks/
  tasks = {
    "devenv-recipes:enterShell:initialize:composer-bin" = {
      description = "Require 'bamarni/composer-bin-plugin' if missing";
      before = [
        "devenv:enterShell"
        "devenv-recipes:enterShell:install:composer"
      ];
      exec = ''
        set -o 'errexit' -o 'pipefail'

        [[ -e '${config.env.DEVENV_ROOT}/composer.json' ]] || exit 0
        if grep --quiet 'bamarni/composer-bin-plugin' '${composer-json}'; then
          exit 0
        fi

        cd '${config.env.DEVENV_ROOT}'
        ${composer-bin} config --json 'allow-plugins.bamarni/composer-bin-plugin' 'true'
        ${composer-bin} config --json 'extra.bamarni-bin.bin-links' 'false'
        ${composer-bin} require --dev 'bamarni/composer-bin-plugin'
      '';
    };
  };
}
