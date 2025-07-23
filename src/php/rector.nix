{
  pkgs,
  config,
  ...
}:
let
  working-dir = "${config.env.DEVENV_ROOT}";
  composer-bin = "${config.languages.php.packages.composer}/bin/composer";
  composer-json = '''';
in
{
  imports = [
    ./composer-bin.nix
  ];

  # https://devenv.sh/packages/
  packages = with pkgs; [ fd ];

  # https://devenv.sh/tasks/
  tasks = {
    "ci:format:rector" = {
      description = "Apply Rector recommendations";
      exec = ''
        set -o 'errexit'
        cd '${working-dir}'
        '${config.languages.php.package}/bin/php' 'vendor/bin/rector' 'process';
      '';
    };
  };

  # https://devenv.sh/tasks/
  tasks = {
    "devenv-recipes:enterShell:initialize:rector" = {
      description = "Initialize Rector composer.json";
      before = [ "devenv:enterShell" ];
      exec = ''
        set -o 'errexit'

        [[ -e '${working-dir}/vendor-bin/rector/composer.json' ]] && exit 0

        mkdir --parent '${working-dir}/vendor-bin/rector' &&
        tee '${working-dir}/vendor-bin/rector/composer.json' << EOF
        ${composer-json}
        EOF
      '';
    };
    "devenv-recipes:enterShell:install:rector" = {
      description = "Install Rector";
      before = [
        "devenv:enterShell"

      ];
      after = [
        "devenv-recipes:enterShell:initialize:composer-bin"
        "devenv-recipes:enterShell:initialize:rector"
        "devenv-recipes:enterShell:install:composer"
      ];
      exec = ''
        set -o 'errexit'
        cd '${working-dir}'
        '${composer-bin}' bin rector install
      '';
    };
  };

  # https://devenv.sh/git-hooks/
  git-hooks.hooks.rector = rec {
    enable = true;
    name = "Rector";
    inherit (config.languages.php) package;
    pass_filenames = false;
    entry = "'${package}/bin/php' '${working-dir}/vendor/bin/rector' 'process'";
    args = [ "--dry-run" ];
  };

  # See full reference at https://devenv.sh/reference/options/
}
