/**
  # PHP 8.4

  PHP is a popular general-purpose scripting language that is especially
  suited to web development.

  ## 🛠️ Tech Stack

  - [PHP homepage](https://www.php.net/).
*/

_: {
  imports = [ ./php.nix ];
  # https://devenv.sh/languages/
  # https://devenv.sh/reference/options/#languagesphpenable
  languages.php.version = "8.4";

  # See full reference at https://devenv.sh/reference/options/
}
