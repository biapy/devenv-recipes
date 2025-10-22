_:

{
  name = "devenv recipes";

  biapy.go-task.enable = true;
  biapy-recipes = {
    git.enable = true;
    nix.enable = true;
    markdown.enable = true;
    shell.enable = true;
    secrets.gitleaks.enable = true;
  };

  # https://devenv.sh/basics/
  env.GREET = "devenv";

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
    commitizen.enable = false;
    shellcheck.enable = false;
  };

  # See full reference at https://devenv.sh/reference/options/
}
