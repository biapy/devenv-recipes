/**
  # Ansible tools

  Ansible tools

  ## 🛠️ Tech Stack

  - [ansible-doctor homepage](https://ansible-doctor.geekdocs.de/)
    ([ansible-doctor @ GitHub](https://github.com/thegeeklab/ansible-doctor)).
  - [Ansible Configuration Management Database (ansible-cmdb) @ GitHub](https://github.com/fboender/ansible-cmdb).
  - [Ansible Builder homepage](https://ansible.readthedocs.io/projects/builder/en/stable/).
  - [Ansible Navigator homepage](https://ansible.readthedocs.io/projects/navigator/).
  - [Ansible Molecule homepage](https://ansible.readthedocs.io/projects/molecule/)
    ([Ansible Molecule @ GitHub](https://github.com/ansible/molecule)).
*/
{ pkgs, ... }:
{
  packages = with pkgs; [
    ansible-cmdb
    ansible-doctor
    ansible-builder
    ansible-navigator
    molecule
  ];
}
