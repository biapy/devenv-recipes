/**
  # Ansible

  Ansible automates the management of remote systems and controls their
  desired state.

  ## 🛠️ Tech Stack

  - [Ansible Community homepage](https://docs.ansible.com/ansible/latest/index.html).
*/
args@{ lib, recipes-lib, ... }:
let
  inherit (lib.lists) map;
in
{
  imports = map (path: import path args) [
    ./ansible.nix
    ./ansible-lint.nix
    ./ansible-tools.nix
  ];

  options.biapy-recipes.ansible = recipes-lib.modules.mkModuleOptions "Ansible";
}
