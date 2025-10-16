/**
  # PHP

  PHP is a popular general-purpose scripting language that is especially
  suited to web development.

  ## 🧐 Features

  ### 🐚 Commands

  - `php-get-ini`: Get PHP ini configuration.
  - `php-modules`: List installed PHP modules.

  ## 🛠️ Tech Stack

  - [PHP homepage](https://www.php.net/).

  ## 🙇 Acknowledgements

  - [languages.php @ devenv](https://devenv.sh/reference/options/#languagesphpenable).
  - [scripts @ Devenv Reference Manual](https://devenv.sh/reference/options/#scripts).
  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
  - [lib.strings.concatStringsSep @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.strings.concatStringsSep).
*/
{ config, lib, ... }:
let
  cfg = config.biapy.php;
  phpCommand = lib.meta.getExe config.languages.php.package;
in
{
  config = lib.mkIf cfg.enable {
    # https://devenv.sh/languages/
    # https://devenv.sh/reference/options/#languagesphpenable
    languages.php = {
      inherit (cfg) enable;

      extensions = [ "xdebug" ];

      ini = lib.concatStringsSep "\n" [
        "xdebug.mode = develop"
        "memory_limit = 256m"
      ];
    };

    # https://devenv.sh/scripts/
    scripts = {
      php-modules = {
        description = "List installed PHP modules";
        exec = ''
          set -o 'errexit' -o 'pipefail'

          echo 'Installed PHP modules'
          echo '---------------------'

          ${phpCommand} -m |
          command grep --invert-match --extended-regexp '^(|\[.*\])$' |
          command tr '\n' ' ' |
          command fold --spaces

          printf '\n---------------------\n'
        '';
      };
      php-get-ini = {
        description = "Get PHP ini configuration";
        exec = ''
          set -o 'errexit' -o 'pipefail'

          print-ini-value() {
            local name="''${1}"

            php --run "printf(\"''${name} = %s\n\",(string) ini_get(\"''${name}\"));"
          }

          php-get-ini() {
            # Check that arg are given in bash
            if [ "''${#}" -eq 0 ]; then
              echo "Usage: php-get-ini <name> [name ...]"
              return 1
            fi
            local names="''${@}"

            for name in ''${names}; do
              print-ini-value "''${name}"
            done
          }

          php-get-ini "''${@}"
        '';
      };
    };

    enterShell = ''
      php --version
      php-modules
      php-get-ini 'memory_limit' 'xdebug.mode' 'xdebug.client_host' 'xdebug.client_port'
    '';

    # See full reference at https://devenv.sh/reference/options/
  };
}
