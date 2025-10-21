/**
  # Ansible

  Ansible automates the management of remote systems and controls their
  desired state.

  ## 🛠️ Tech Stack

  - [Ansible Community homepage](https://docs.ansible.com/ansible/latest/index.html).

  ### 🧑‍💻 Visual Studio Code

  - [Ansbible @ Visual Studio Code Marketplace](https://marketplace.visualstudio.com/items?itemName=redhat.ansible).

  ## 🙇 Acknowledgements

  - [languages.ansible @ devenv](https://devenv.sh/reference/options/#languagesansibleenable).
*/
{ config, lib, ... }:
let
  inherit (lib.modules) mkIf;

  cfg = config.biapy-recipes.ansible;
in
{
  config = mkIf cfg.enable {
    languages.ansible.enable = true;

    # https://devenv.sh/integrations/codespaces-devcontainer/
    devcontainer.settings.customizations.vscode.extensions = [ "redhat.ansible" ];
  };
}
