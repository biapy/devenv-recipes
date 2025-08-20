/**
  # Nil

  Nil is a Nix Language server,
  an incremental analysis assistant for writing in Nix.

  ## 🛠️ Tech Stack

  - [nil @ GitHub](https://github.com/oxalica/nil).
  - [fd @ GitHub](https://github.com/sharkdp/fd).
  - [Nix IDE @ Visual Studio Code Marketplace](https://marketplace.visualstudio.com/items?itemName=jnoortheen.nix-ide).

  ## 🙇 Acknowledgements

  - [lib.meta.getExe @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.meta.getExe).
  - [git-hooks.hooks.nil @ Devenv Reference Manual](https://devenv.sh/reference/options/#git-hookshooksnil).
  - [devcontainer @ Devenv Reference Manual](https://devenv.sh/reference/options/#devcontainerenable).
*/
{
  pkgs,
  config,
  lib,
  ...
}:
let
  nilCommand = lib.meta.getExe config.git-hooks.hooks.nil.package;
  inherit (pkgs) fd;
  fdCommand = lib.meta.getExe fd;
in
{
  imports = [ ./nix.nix ];

  devcontainer.settings.customizations.vscode.extensions = [ "jnoortheen.nix-ide" ];

  packages = [ fd ];

  # https://devenv.sh/git-hooks/
  git-hooks.hooks.nil.enable = true;

  # https://devenv.sh/tasks/
  tasks."ci:lint:nix:nil" = {
    description = "Lint *.nix files with nil";
    exec = ''
      set -o 'errexit' -o 'pipefail'

      cd "''${DEVENV_ROOT}"
      ${fdCommand} '\.nix$' "''${DEVENV_ROOT}" --exec-batch ${nilCommand} 'diagnostics'
    '';
  };

}
