{
  pkgs,
  config,
  ...
}:
let
  working-dir = "${config.env.DEVENV_ROOT}";
  composer-bin = "${config.languages.php.packages.composer}/bin/composer";
  composer-json = ''
    {
        "require-dev": {
            "phpstan/extension-installer": "^1.4",
            "phpstan/phpstan": "^2.1",
            "phpstan/phpstan-deprecation-rules": "^2.0",
            "phpstan/phpstan-doctrine": "^2.0",
            "phpstan/phpstan-phpunit": "^2.0",
            "phpstan/phpstan-strict-rules": "^2.0",
            "phpstan/phpstan-symfony": "^2.0",
            "rector/type-perfect": "^2.1",
            "symplify/phpstan-rules": "^14.6"
        },
        "config": {
            "allow-plugins": {
                "phpstan/extension-installer": true
            }
        },
        "scripts": {
            "post-install-cmd": [
                "@install-link"
            ],
            "install-link": [
                "test -e '../../vendor/bin/phpstan' || ln --symbolic ../../vendor-bin/phpstan/vendor/bin/phpstan ../../vendor/bin/phpstan"
            ]
        },
        "scripts-descriptions": {
            "install-link": "Install composer bin link"
        }
    }
  '';
in
{
  imports = [
    ./composer-bin.nix
  ];

  # https://devenv.sh/packages/
  packages = with pkgs; [ fd ];

  # https://devenv.sh/tasks/
  tasks = {
    "ci:lint:phpstan".exec = ''
      set -o 'errexit' -o 'pipefail'
      cd '${working-dir}'
      '${config.languages.php.package}/bin/php' 'vendor/bin/phpstan' 'analyse';
    '';
  };

  # https://devenv.sh/tasks/
  tasks = {
    "devenv-recipes:enterShell:initialize:phpstan" = {
      description = "Initialize PHPStan composer.json";
      before = [ "devenv:enterShell" ];
      exec = ''
        set -o 'errexit'

        [[ -e '${working-dir}/vendor-bin/phpstan/composer.json' ]] && exit 0

        mkdir --parent '${working-dir}/vendor-bin/phpstan' &&
        tee '${working-dir}/vendor-bin/phpstan/composer.json' << EOF
        ${composer-json}
        EOF
      '';
    };
    "devenv-recipes:enterShell:install:phpstan" = {
      description = "Install PHPStan";
      before = [
        "devenv:enterShell"

      ];
      after = [
        "devenv-recipes:enterShell:initialize:composer-bin"
        "devenv-recipes:enterShell:initialize:phpstan"
        "devenv-recipes:enterShell:install:composer"
      ];
      exec = ''
        set -o 'errexit'
        '${composer-bin}' --working-dir='${working-dir}' bin phpstan install
      '';
    };
  };

  # https://devenv.sh/git-hooks/
  git-hooks.hooks.phpstan = rec {
    enable = true;
    name = "PHPStan";
    inherit (config.languages.php) package;
    pass_filenames = false;
    entry = "'${package}/bin/php' '${working-dir}/vendor/bin/phpstan' 'analyse'";
    args = [ "--memory-limit=256m" ];
  };

  # See full reference at https://devenv.sh/reference/options/
}
