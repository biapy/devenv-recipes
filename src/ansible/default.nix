/**
  # Ansible

  Ansible automates the management of remote systems and controls their
  desired state.

  ## 🛠️ Tech Stack

  - [Ansible Community homepage](https://docs.ansible.com/ansible/latest/index.html).
*/
_: {
  imports = [
    ./ansible.nix
    ./ansible-lint.nix
  ];
}
