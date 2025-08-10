/**
  # PostgreSQL

  PostgreSQL is a powerful, open source object-relational database system.

  ## 🛠️ Tech Stack

  - [PostgreSQL homepage](https://www.postgresql.org/).

  ### Terminal User Interface tools

  - [dblab @ GitHub](https://github.com/danvergara/dblab).
  - [Harlequin homepage](https://harlequin.sh/)
    ([Harlequin @ GitHub](https://github.com/tconbeer/harlequin)).
  - [Lazysql @ GitHub](https://github.com/jorgerojas26/lazysql).
  - [pgtui @ Codeberg](https://codeberg.org/ihabunek/pgtui).
  - [Rainfrog @ GitHub](https://github.com/achristmascarl/rainfrog).

  ## 🙇 Acknowledgements

  - [Setting priorities @ NixOS Manual](https://nixos.org/manual/nixos/stable/#sec-option-definitions-setting-priorities).
*/
{
  pkgs,
  lib,
  config,
  ...
}:

{
  # https://devenv.sh/basics/
  env = {
    POSTGRES_USER = lib.mkDefault "postgres";
    POSTGRES_PASSWORD = lib.mkDefault "postgres";
    POSTGRES_DB = lib.mkDefault "postgres_doctrine_test";
    POSTGRES_PORT = lib.mkDefault 5432;
  };

  # https://devenv.sh/packages/
  packages = with pkgs; [
    dblab
    harlequin
    lazysql
    pgtui
    rainfrog
  ];

  # https://devenv.sh/services/
  services.postgres = {
    enable = true;

    listen_addresses = "127.0.0.1";
    port = config.env.POSTGRES_PORT;

    initialDatabases = [ { name = config.env.POSTGRES_DB; } ];

    initialScript = ''
      CREATE ROLE "${config.env.POSTGRES_USER}"
        WITH SUPERUSER LOGIN PASSWORD '${config.env.POSTGRES_PASSWORD}';
    '';
  };

  # https://devenv.sh/tasks/
  tasks = {
    "devenv-recipes:services:reset:postgresql" = {
      description = "Reset PostgreSQL data";
      exec = ''
        set -o 'errexit'
        echo "Deleting PostgreSQL data in ''${PGDATA}"
        [[ -e "''${PGDATA}" ]] &&
        rm -r "''${PGDATA}"
      '';
    };
  };

  enterShell = ''
    postgres --version
    echo "Storage: ''${PGDATA}"
  '';

  # https://devenv.sh/tests/
  enterTest = ''
    echo "Running tests"
    postgres --version | grep --color=auto "${config.services.postgres.package.version}"
  '';
}
