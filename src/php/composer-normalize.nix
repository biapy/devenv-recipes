{
  pkgs,
  config,
  ...
}:
let
  working-dir = "${config.env.DEVENV_ROOT}";
  composer-bin = "${config.languages.php.packages.composer}/bin/composer";
  parallel-bin = "${pkgs.parallel}/bin/parallel";
  composer-json = ''
    {
        "require-dev": {
            "ergebnis/composer-normalize": "^2.47"
        },
        "config": {
            "allow-plugins": {
                "ergebnis/composer-normalize": true
            }
        },
        "scripts": {
            "install-link": [
                "::"
            ]
        },
        "scripts-descriptions": {
            "install-link": "Dummy script for consistency"
        }
    }
  '';
in
{
  imports = [
    ../gnu-parallel.nix
    ./composer-bin.nix
  ];

  # https://devenv.sh/packages/
  packages = with pkgs; [ fd ];

  # https://devenv.sh/tasks/
  tasks = {
    "ci:format:composer-normalize".exec = ''
      set -o 'errexit' -o 'pipefail'
      cd '${working-dir}'
      ${pkgs.fd}/bin/fd 'composer\.json$' '${working-dir}' --exec '${composer-bin}' bin composer-normalize normalize {} \;
    '';
  };

  # https://devenv.sh/tasks/
  tasks = {
    "devenv-recipes:enterShell:initialize:composer-normalize" = {
      description = "Initialize composer normalize composer.json";
      before = [ "devenv:enterShell" ];
      exec = ''
        set -o 'errexit'

        [[ -e '${working-dir}/vendor-bin/composer-normalize/composer.json' ]] && exit 0

        mkdir --parent '${working-dir}/vendor-bin/composer-normalize' &&
        tee '${working-dir}/vendor-bin/composer-normalize/composer.json' << EOF
        ${composer-json}
        EOF
      '';
    };
    "devenv-recipes:enterShell:install:composer-normalize" = {
      description = "Install composer normalize";
      before = [
        "devenv:enterShell"

      ];
      after = [
        "devenv-recipes:enterShell:initialize:composer-bin"
        "devenv-recipes:enterShell:initialize:composer-normalize"
        "devenv-recipes:enterShell:install:composer"
      ];
      exec = ''
        set -o 'errexit'
        cd '${working-dir}'
        '${composer-bin}' bin composer-normalize install
      '';
    };
  };

  # https://devenv.sh/git-hooks/
  git-hooks.hooks = {
    composer-normalize = {
      enable = true;
      name = "composer normalize";
      before = [ "composer-validate" ];
      package = config.languages.php.packages.composer;
      extraPackages = [ pkgs.parallel ];
      files = "composer.json";
      entry = "'${parallel-bin}' '${composer-bin}' bin composer-normalize normalize --dry-run '${working-dir}/'{} ::: ";
    };
  };

  # See full reference at https://devenv.sh/reference/options/
}
