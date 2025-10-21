/**
  # Shell

  Shell scripting is a powerful way to automate tasks and manipulate files
  in UNIX-like operating systems.

  ## 🛠️ Tech Stack

  - [GNU Bash homepage](https://www.gnu.org/software/bash/bash.html).

  ## 🙇 Acknowledgements

  - [languages.shell @ devenv](https://devenv.sh/reference/options/#languagesshellenable).
  - [lib.strings.concatStringsSep @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.strings.concatStringsSep).
*/
{ config, lib, ... }:
let
  inherit (lib.modules) mkIf;

  cfg = config.biapy-recipes.shell;
in
{
  config = mkIf cfg.enable {
    # https://devenv.sh/languages/
    # https://devenv.sh/reference/options/#languagesshellenable
    languages.shell.enable = true;

    enterShell = ''
      bash --version
    '';

    # See full reference at https://devenv.sh/reference/options/
  };
}
