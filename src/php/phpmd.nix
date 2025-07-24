{ pkgs, config, ... }:
let
  utils = import ../utils { inherit config; };
  working-dir = "${config.env.DEVENV_ROOT}";
  tool = {
    name = "PHP Mess Detector";
    namespace = "phpmd";
    composerJsonPath = ./files/vendor-bin/phpmd/composer.json;
    configFile = "phpmd.xml.dist";
    configFilePath = ./files/phpmd.xml.dist;
  };
in
{
  imports = [
    ../gnu-parallel.nix
    ./composer-bin.nix
  ];

  # https://devenv.sh/tasks/
  tasks =
    {
      "ci:lint:phpmd" = {
        description = "Lint 'src' and 'tests' with PHP Mess Detector";
        exec = ''
          set -o 'errexit'
          cd '${working-dir}'
          '${config.languages.php.package}/bin/php' -d 'error_reporting=~E_DEPRECATED' '${working-dir}/vendor/bin/phpmd' '${working-dir}/'{src,tests} 'ansi' '${working-dir}/phpmd.xml.dist'
        '';
      };
    }
    // utils.composer-bin.initializeComposerJsonTask tool
    // utils.composer-bin.initializeConfigFileTask tool
    // utils.composer-bin.installTask tool;

  # https://devenv.sh/git-hooks/
  git-hooks.hooks.phpmd = rec {
    enable = true;
    name = "PHP Mess Detector";
    inherit (config.languages.php) package;
    extraPackages = [ pkgs.parallel ];
    entry = "'${pkgs.parallel}/bin/parallel' '${package}/bin/php' -d 'error_reporting=~E_DEPRECATED' '${working-dir}/vendor/bin/phpmd' {} 'ansi' '${working-dir}/phpmd.xml.dist' ::: ";
  };

  # See full reference at https://devenv.sh/reference/options/
}
