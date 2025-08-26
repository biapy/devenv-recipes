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

  - `ansible`: Lint Ansible files with `ansible-lint`.

  ## 🛠️ Tech Stack

  - [Ansible Lint homepage](https://ansible.readthedocs.io/projects/lint/).
  - [Ansible Lint @ GitHub](https://github.com/ansible/ansible-lint).

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
  - [git-hooks.hooks.php-cs-fixer @ Devenv Reference Manual](https://devenv.sh/reference/options/#git-hookshooksphp-cs-fixer).
  - [devcontainer @ Devenv Reference Manual](https://devenv.sh/reference/options/#devcontainerenable).
*/
{ config, lib, ... }:
let
  ansible-lint = config.git-hooks.hooks.ansible-lint.package;
  ansibleLintCommand = lib.meta.getExe ansible-lint;
in
{
  # https://devenv.sh/tasks/
  tasks = {
    "ci:lint:ansible:ansible-lint".exec = ''
      cd "''${DEVENV_ROOT}"
      '${ansibleLintCommand}'
    '';
  };

  git-hooks.hooks.ansible-lint.enable = true;
}
