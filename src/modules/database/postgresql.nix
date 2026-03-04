/**
    # PostgreSQL

    PostgreSQL is a powerful, open source object-relational database system.

    ## 🧐 Features

    ### 🔨 Tasks

    - `devenv-recipes:reset:services:postgresql`: Delete PostgreSQL data.

    ### 🧙 Services

    - `postgres`: PostgreSQL service, on port 5432.

    ### 🐚 Terminal User Interface tools

    - [dblab @ GitHub](https://github.com/danvergara/dblab).
    - [Harlequin homepage](https://harlequin.sh/)
      ([Harlequin @ GitHub](https://github.com/tconbeer/harlequin)).
    - [Lazysql @ GitHub](https://github.com/jorgerojas26/lazysql).
    - [Rainfrog @ GitHub](https://github.com/achristmascarl/rainfrog).

    ## 🛠️ Tech Stack

    - [PostgreSQL homepage](https://www.postgresql.org/).

    ## 🙇 Acknowledgements

    - [Setting priorities @ NixOS Manual](https://nixos.org/manual/nixos/stable/#sec-option-definitions-setting-priorities).
    - [pgtui @ Codeberg](https://codeberg.org/ihabunek/pgtui).
*/
{
  config,
  lib,
  pkgs,
  recipes-lib,
  ...
}:
let
  inherit (lib) mkOption types;
  inherit (lib.modules) mkDefault mkIf;
  inherit (lib.strings) toInt;
  inherit (recipes-lib.go-tasks) patchGoTask;

  databaseCfg = config.biapy-recipes.database;
  cfg = databaseCfg.postgresql;
in
{
  options.biapy-recipes.database.postgresql = {
    enable = mkOption {
      type = types.bool;
      description = "Enable PostgreSQL integration";
      default = false;
    };

    enterShellMessages = mkOption {
      type = types.bool;
      default = true;
      description = "Display PostgreSQL information when entering the shell.";
    };
  };

  config = mkIf cfg.enable {
    # https://devenv.sh/basics/
    env = {
      POSTGRES_USER = mkDefault "postgres";
      POSTGRES_PASSWORD = mkDefault "postgres";
      POSTGRES_DB = mkDefault "postgres_doctrine_test";
      POSTGRES_PORT = mkDefault "5432";
    };

    # https://devenv.sh/packages/
    packages = with pkgs; [
      dblab
      harlequin
      lazysql
      rainfrog
    ];

    # https://devenv.sh/services/
    services.postgres = {
      enable = mkDefault true;

      listen_addresses = mkDefault "127.0.0.1";
      port = mkDefault toInt config.env.POSTGRES_PORT;

      initialDatabases = mkDefault [ { name = config.env.POSTGRES_DB; } ];

      initialScript = mkDefault ''
        CREATE ROLE "${config.env.POSTGRES_USER}"
          WITH SUPERUSER LOGIN PASSWORD '${config.env.POSTGRES_PASSWORD}';
      '';
    };

    # https://devenv.sh/tasks/
    tasks = {
      "reset:database:postgresql" = {
        description = mkDefault "🔥 Delete 🗃️PostgreSQL data";
        exec = mkDefault ''
          echo "Deleting PostgreSQL data in ''${PGDATA}"
          [[ -e "''${PGDATA}" ]] &&
            rm -r "''${PGDATA}"
        '';
      };
    };

    biapy.go-task.taskfile.tasks = {
      "reset:database:postgresql" = patchGoTask {
        aliases = mkDefault [ "reset:database:pgsql" ];
        desc = mkDefault "🔥 Delete 🗃️PostgreSQL data";
        cmds = mkDefault [
          ''echo "Deleting PostgreSQL data in ''${PGDATA}"''
          ''[[ -e "''${PGDATA}" ]] && rm -r "''${PGDATA}"''
        ];
        requires.vars = mkDefault [ "PGDATA" ];
      };
    };

    enterShell = mkIf cfg.enterShellMessages ''
      postgres --version
      echo "Storage: ''${PGDATA}"
    '';

    # https://devenv.sh/tests/
    enterTest = ''
      echo "Running tests"
      postgres --version | grep --color=auto "${config.services.postgres.package.version}"
    '';
  };
}
