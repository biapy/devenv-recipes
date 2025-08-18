/**
  # PHP

  PHP is a popular general-purpose scripting language that is especially
  suited to web development.

  ## 🛠️ Tech Stack

  - [PHP homepage](https://www.php.net/).

  ## 🙇 Acknowledgements

  - [languages.php @ devenv](https://devenv.sh/reference/options/#languagesphpenable).
  - [lib.strings.concatStringsSep @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.strings.concatStringsSep).
*/
{ config, lib, ... }:
let
  phpCommand = lib.meta.getExe config.languages.php.package;
in
{
  # https://devenv.sh/languages/
  # https://devenv.sh/reference/options/#languagesphpenable
  languages.php = {
    enable = true;

    ini = lib.concatStringsSep "\n" [
      "xdebug.mode = develop"
      "memory_limit = 256m"
    ];

  };
  # https://devenv.sh/scripts/
  scripts.php-modules.exec = ''
    set -o 'errexit' -o 'pipefail'

    echo 'Installed PHP modules'
    echo '---------------------'

    ${phpCommand} -m |
    command grep --invert-match --extended-regexp '^(|\[.*\])$' |
    command tr '\n' ' ' |
    command fold --spaces

    printf '\n---------------------\n'
  '';

  enterShell = ''
    php --version
    php-modules
  '';

  # See full reference at https://devenv.sh/reference/options/
}
