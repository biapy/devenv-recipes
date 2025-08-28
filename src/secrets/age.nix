/**
  # age

  `age` is a simple, modern and secure file encryption tool, format,
  and Go library.

  ## 🛠️ Tech Stack

  - [age @ GitHub](https://github.com/FiloSottile/age).

  ### 🦀 Rust alternatives

  - [rage @ GitHub](https://github.com/str4d/rage).
*/
{ pkgs, ... }:
let
  inherit (pkgs) age;
in
{
  packages = [ age ];
}
