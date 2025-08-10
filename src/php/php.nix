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
    # extensions = [
    #   "dom"
    #   "filter"
    #   "iconv"
    #   "mbstring"
    #   "openssl"
    #   "pdo_pgsql"
    #   "pdo_sqlite"
    #   "xdebug"
    #   "xmlwriter"
    # ];
    disableExtensions = [
      "dom"
      # "filter"
      # "iconv"
      # "mbstring"
      # "openssl"
      "pdo_pgsql"
      "pdo_sqlite"
      "xdebug"
      "xmlwriter"
      # "ctype"
      # "simplexml"

      "bcmath"
      "calendar"
      "curl"
      "date"
      "exif"
      "fileinfo"
      "ftp"
      "gd"
      "gettext"
      "gmp"
      "imap"
      "intl"
      "ldap"
      "mysqli"
      "mysqlnd"
      "opcache"
      "pcntl"
      "pdo_mysql"
      "pdo_odbc"
      "posix"
      "readline"
      "session"
      "soap"
      "sockets"
      "sodium"
      "sysvsem"
      "xmlreader"
      "zip"
      "zlib"
    ];

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
