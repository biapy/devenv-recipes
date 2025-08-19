_:

{
  name = "devenv recipes";

  imports = [
    src/git.nix
    src/devenv-scripts.nix
    src/markdown
    src/gitleaks.nix
    src/nix.nix
  ];

  # https://devenv.sh/basics/
  env.GREET = "devenv";

  # https://devenv.sh/languages/
  # languages.rust.enable = true;

  # https://devenv.sh/processes/
  # processes.cargo-watch.exec = "cargo-watch";

  # https://devenv.sh/services/
  # services.postgres.enable = true;

  # https://devenv.sh/scripts/
  scripts.hello.exec = ''
    echo hello from $GREET
  '';

  enterShell = ''
    hello
    git --version
  '';

  # https://devenv.sh/tasks/
  # tasks = {
  #   "myproj:setup".exec = "mytool build";
  #   "devenv:enterShell".after = [ "myproj:setup" ];
  # };

  # https://devenv.sh/tests/
  enterTest = ''
    echo "Running tests"
  '';

  # https://devenv.sh/git-hooks/
  git-hooks.hooks = {
    commitizen.enable = true;
    # shellcheck.enable = true;
  };

  # See full reference at https://devenv.sh/reference/options/
}
