/**
  # Shell

  Shell scripting is a powerful way to automate tasks and manipulate files
  in UNIX-like operating systems.

  ## 🧐 Features

  ### 🐚 Commands

  - `php-modules`: List installed PHP modules.

  ## 🛠️ Tech Stack

  - [GNU Bash homepage](https://www.gnu.org/software/bash/bash.html).

  ## 🙇 Acknowledgements

  - [languages.shell @ devenv](https://devenv.sh/reference/options/#languagesshellenable).
  - [lib.strings.concatStringsSep @ Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.strings.concatStringsSep).
*/
_: {
  # https://devenv.sh/languages/
  # https://devenv.sh/reference/options/#languagesshellenable
  languages.shell.enable = true;

  enterShell = ''
    bash --version
  '';

  # See full reference at https://devenv.sh/reference/options/
}
