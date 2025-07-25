{ pkgs, config, ... }:
let
  composerCommand = "${config.languages.php.packages.composer}/bin/composer";
  parallelCommand = "${pkgs.parallel}/bin/parallel";
in
{
  imports = [ ../gnu-parallel.nix ];

  languages.php.enable = true;

  enterShell = ''
    hello
    git --version

    export PATH="${config.env.DEVENV_ROOT}/vendor/bin:${config.env.DEVENV_ROOT}/bin:$PATH"
  '';

  # https://devenv.sh/tasks/
  tasks = {
    "devenv-recipes:enterShell:install:composer" = {
      description = "Install composer packages";
      before = [ "devenv:enterShell" ];
      exec = ''
        set -o 'errexit'
        [[ -e "''${DEVENV_ROOT}/composer.json" ]] &&
        ${composerCommand} 'install'
      '';
    };
  };

  # https://devenv.sh/git-hooks/
  git-hooks.hooks = {
    composer-validate = rec {
      enable = true;
      name = "composer validate";
      package = config.languages.php.packages.composer;
      extraPackages = [ pkgs.parallel ];
      files = "composer\.(json|lock)$";
      entry = ''"${parallelCommand}" "${package}/bin/composer" validate --no-check-publish {} ::: '';
      stages = [
        "pre-commit"
        "pre-push"
      ];
    };

    composer-audit = rec {
      enable = true;
      name = "composer audit";
      after = [ "composer-validate" ];
      package = config.languages.php.packages.composer;
      extraPackages = [ pkgs.parallel ];
      files = "composer\.(json|lock)$";
      verbose = true;
      entry = ''"${parallelCommand}" "${package}/bin/composer" --working-dir="''${DEVENV_ROOT}" audit ::: '';
      stages = [
        "pre-commit"
        "pre-push"
      ];
    };
  };

  # See full reference at https://devenv.sh/reference/options/
}
