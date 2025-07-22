{
  pkgs,
  config,
  ...
}:
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
        [[ -e '${config.env.DEVENV_ROOT}/composer.json' ]] &&
          ${config.languages.php.packages.composer}/bin/composer 'install'
      '';
    };
  };

  # https://devenv.sh/git-hooks/
  git-hooks.hooks = {
    composer-validate = {
      enable = true;
      name = "composer validate";
      package = config.languages.php.packages.composer;
      extraPackages = [ pkgs.parallel ];
      files = "composer\.(json|lock)$";
      entry = "${pkgs.parallel}/bin/parallel ${config.languages.php.packages.composer}/bin/composer validate --no-check-publish {} ::: ";
      stages = [
        "pre-commit"
        "pre-push"
      ];
    };

    composer-audit = {
      enable = true;
      name = "composer audit";
      after = [ "composer-validate" ];
      package = config.languages.php.packages.composer;
      extraPackages = [
        pkgs.parallel
        pkgs.coreutils
      ];
      files = "composer\.(json|lock)$";
      verbose = true;
      entry = "${pkgs.parallel}/bin/parallel ${config.languages.php.packages.composer}/bin/composer --working-dir=\"$(${pkgs.coreutils}/bin/dirname {})\" audit ::: ";
      stages = [
        "pre-commit"
        "pre-push"
      ];
    };
  };

  # See full reference at https://devenv.sh/reference/options/
}
