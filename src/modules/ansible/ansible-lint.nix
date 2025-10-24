/**
  # Ansible Lint

  Ansible Lint is a command-line tool for linting playbooks, roles,
  and collections aimed toward any Ansible users.
  Its main goal is to promote proven practices, patterns, and behaviors while
  avoiding common pitfalls that can easily lead to bugs
  or make code harder to maintain.

  ## 🧐 Features

  ### 🔨 Tasks

  - `ci:lint:ansible:ansible-lint`: Lint Ansible files with `ansible-lint`.

  ### 👷 Commit hooks

  - `ansible-lint`: Lint Ansible files with `ansible-lint`.

  ## 🛠️ Tech Stack

  - [Ansible Lint homepage](https://ansible.readthedocs.io/projects/lint/).
  - [Ansible Lint @ GitHub](https://github.com/ansible/ansible-lint).

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
  - [git-hooks.hooks.php-cs-fixer @ Devenv Reference Manual](https://devenv.sh/reference/options/#git-hookshooksphp-cs-fixer).
  - [devcontainer @ Devenv Reference Manual](https://devenv.sh/reference/options/#devcontainerenable).
*/
{
  config,
  lib,
  recipes-lib,
  ...
}:
let
  inherit (lib.modules) mkIf mkDefault;
  inherit (recipes-lib.modules) mkToolOptions;
  inherit (recipes-lib.go-tasks) patchGoTask;
  inherit (lib.attrsets) optionalAttrs;

  ansibleCfg = config.biapy-recipes.ansible;
  cfg = ansibleCfg.ansible-lint;

  ansible-lint = config.git-hooks.hooks.ansible-lint.package;
  ansibleLintCommand = lib.meta.getExe ansible-lint;
in
{
  options.biapy-recipes.ansible.ansible-lint = mkToolOptions ansibleCfg "ansible-lint";

  config = mkIf cfg.enable {
    packages = [ ansible-lint ];

    git-hooks.hooks = optionalAttrs cfg.git-hooks { ansible-lint.enable = mkDefault true; };

    # https://devenv.sh/tasks/
    tasks = optionalAttrs cfg.tasks {
      "ci:lint:ansible:ansible-lint" = {
        description = "🔍 Lint 🔧Ansible configuration with ansible-lint";
        exec = ''
          cd "''${DEVENV_ROOT}"
          '${ansibleLintCommand}'
        '';
      };
    };

    biapy.go-task.taskfile.tasks = optionalAttrs cfg.go-task {
      "ci:lint:ansible:ansible-lint" = patchGoTask {
        desc = "🔍 Lint 🔧Ansible configuration with ansible-lint";
        cmds = [ "ansible-lint" ];
      };
    };
  };
}
