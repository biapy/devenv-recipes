args@{
  config,
  lib,
  recipes-lib,
  ...
}:
let
  inherit (lib) types mkOption;
  inherit (lib.modules) mkIf mkDefault;
  inherit (lib.lists) map;
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.strings) concatStringsSep;

  php-recipe-lib = import ./lib.nix args;

  imports-args = args // {
    inherit php-recipe-lib;
  };

  cfg = config.biapy-recipes.php;
  phpCommand = lib.meta.getExe config.languages.php.package;
in
{
  imports = map (path: import path imports-args) [
    ./tools
    ./box.nix
    ./composer.nix
    ./phpactor.nix
    ./symfony.nix
  ];

  options.biapy-recipes.php = (recipes-lib.modules.mkModuleOptions "PHP") // {
    ini = mkOption {
      type = types.attrsOf types.str;
      default = {
        "xdebug.mode" = "develop,coverage,debug,gcstats,profile,trace";
        "xdebug.start_with_request" = "trigger";
        "xdebug.remote_enable" = "1";
        "memory_limit" = "256m";
      };
      apply =
        iniSettings: concatStringsSep "\n" (mapAttrsToList (name: value: "${name} = ${value}") iniSettings);
      description = ''
        Additional PHP INI settings to apply.
      '';
    };

    enterShellMessages = mkOption {
      type = types.bool;
      default = true;
      description = ''Display PHP information when entering the shell.'';
    };
  };

  config = mkIf cfg.enable {
    # https://devenv.sh/languages/
    # https://devenv.sh/reference/options/#languagesphpenable
    languages.php = {
      inherit (cfg) enable ini;

      extensions = [ "xdebug" ];
      version = mkDefault "8.4";
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

            ${phpCommand} --run "printf(\"''${name} = %s\n\",(string) ini_get(\"''${name}\"));"
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

    enterShell = mkIf cfg.enterShellMessages ''
      php --version
      php-modules
      php-get-ini 'memory_limit' 'xdebug.mode' 'xdebug.client_host' 'xdebug.client_port'
    '';

    # See full reference at https://devenv.sh/reference/options/
  };
}
