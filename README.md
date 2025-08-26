# devenv-recipes

Recipes for [Cachix devenv](https://devenv.sh/).

<!-- CSpell:ignore Cachix devenv -->

## 🧑🏻‍💻 Usage

Add `nixpkgs-unstable` and `devenv-recipes` inputs to `devenv.yaml`:

```yaml
# devenv.yaml
inputs:
  …
  nixpkgs-unstable:
    url: github:nixos/nixpkgs/nixpkgs-unstable
  devenv-recipes:
    url: github:biapy/devenv-recipes?dir=src
    flake: false
```

<!-- CSpell:ignore biapy nixpkgs nixos -->

Update `devenv.lock`:

```bash
devenv update
```

Add the wished imports to `devenv.nix`, here for a Nix project:

```nix
# devenv.nix
{inputs, ...}: {
  imports = [
    "${inputs.devenv-recipes}/devenv-scripts.nix"
    "${inputs.devenv-recipes}/git.nix"
    "${inputs.devenv-recipes}/devcontainer.nix"
    "${inputs.devenv-recipes}/markdown"
    "${inputs.devenv-recipes}/nix"
    "${inputs.devenv-recipes}/secrets"
  ];
  # …
}
```

## 🛠️ Tech Stack

- [Nix](https://nixos.org/)
- [devenv](https://devenv.sh/)

## 🙇 Acknowledgements

- [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
- [Gitmoji](https://gitmoji.dev/)
- [GitHub Simp](https://readmi.xyz/)

<!-- CSpell:ignore Gitmoji -->

## ➤ License

Distributed under the MIT License. See [LICENSE](LICENSE) for more information.
