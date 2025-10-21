/**
  # Ansible

  Ansible automates the management of remote systems and controls their
  desired state.

  ## 🛠️ Tech Stack

  - [Ansible Community homepage](https://docs.ansible.com/ansible/latest/index.html).
*/
{
  config,
  lib,
  pkgs,
  ...
}@args:
let
  inherit (lib.lists) map;
  recipes-lib = import ../../lib args;
  imports-args = {
    inherit
      config
      lib
      pkgs
      recipes-lib
      ;
  };

in
{
  imports = map (path: import path imports-args) [
    ./ansible.nix
    ./ansible-lint.nix
    ./ansible-tools.nix
  ];

  options.biapy-recipes.ansible = recipes-lib.modules.mkModuleOptions "Ansible";
}
