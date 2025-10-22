{
  config,
  lib,
  pkgs,
  php-recipe-lib,
  recipes-lib,
  ...
}:
let
  inherit (lib) types mkOption;
  inherit (lib.strings) optionalString match;
  inherit (lib.lists) map head;
  inherit (recipes-lib.tasks) mkGitIgnoreTask;
  imports-args = {
    inherit
      config
      lib
      pkgs
      recipes-lib
      php-recipe-lib
      ;
  };

  phpCfg = config.biapy-recipes.php;
  cfg = config.biapy-recipes.php.tools;

  trimSlashes =
    str:
    let
      result = match "[/]*(.*[^/])[/]*" str;
    in
    optionalString (result != null) (head result);

in
{
  imports = map (path: import path imports-args) [
    ./composer-normalize.nix
    ./php-cs-fixer.nix
    ./phpcs.nix
    ./phpmd.nix
    ./phpstan.nix
    ./rector.nix
  ];

  options.biapy-recipes.php.tools = {
    enable = mkOption {
      type = types.bool;
      default = phpCfg.enable;
      description = ''
        Enable installation of PHP tools in the project.
      '';
    };

    path = mkOption {
      type = types.str;
      default = "tools/";
      apply = trimSlashes;
      description = ''
        Specify the folder where to install PHP tools in the project.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # https://devenv.sh/tasks/
    tasks = mkGitIgnoreTask {
      name = "PHP tools";
      namespace = "php:tools";
      ignoredPaths = [ "/${cfg.path}/**/vendor/" ];
    };
  };
}
