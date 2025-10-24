{ lib, ... }:
let
  inherit (lib.attrsets) isAttrs zipAttrsWith;
  inherit (lib.lists)
    all
    concatLists
    head
    isList
    last
    tail
    unique
    ;
in
{
  # See https://discourse.nixos.org/t/nix-function-to-merge-attributes-records-recursively-and-concatenate-arrays/2030/7
  # See https://stackoverflow.com/questions/54504685/nix-function-to-merge-attributes-records-recursively-and-concatenate-arrays/54505212#54505212
  recursiveMerge =
    attrList:
    let
      f =
        attrPath:
        zipAttrsWith (
          n: values:
          if tail values == [ ] then
            head values
          else if all isList values then
            unique (concatLists values)
          else if all isAttrs values then
            f (attrPath ++ [ n ]) values
          else
            last values
        );
    in
    f [ ] attrList;

}
