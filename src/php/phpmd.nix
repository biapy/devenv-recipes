{ pkgs, config, ... }:
let
  utils = import ../utils { inherit config; };
  composerBinTool = {
    name = "PHP Mess Detector";
    namespace = "phpmd";
    composerJsonPath = ./files/vendor-bin/phpmd/composer.json;
    configFiles = {
      "phpmd.xml.dist" = ./files/phpmd.xml.dist;
    };
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
      "ci:lint:php:phpmd" = {
        description = "Lint 'src' and 'tests' with PHP Mess Detector";
        exec = ''
          set -o 'errexit'
          cd "''${DEVENV_ROOT}"'
          '${config.languages.php.package}/bin/php' -d 'error_reporting=~E_DEPRECATED' 'vendor/bin/phpmd' {src,tests} 'ansi' 'phpmd.xml.dist'
        '';
      };
    }
    // utils.composer-bin.initializeComposerJsonTask composerBinTool
    // utils.composer-bin.initializeConfigFilesTask composerBinTool
    // utils.composer-bin.installTask composerBinTool;

  # https://devenv.sh/git-hooks/
  git-hooks.hooks.phpmd = rec {
    enable = true;
    name = "PHP Mess Detector";
    inherit (config.languages.php) package;
    extraPackages = [ pkgs.parallel ];
    entry = ''"${pkgs.parallel}/bin/parallel" '${package}/bin/php' -d 'error_reporting=~E_DEPRECATED' "''${DEVENV_ROOT}/vendor/bin/phpmd" {} 'ansi' "''${DEVENV_ROOT}/phpmd.xml.dist" ::: '';
  };

  # See full reference at https://devenv.sh/reference/options/
}
