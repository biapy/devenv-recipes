# devenv-recipes

Recipes for [Cachix devenv](https://devenv.sh/).

<!-- CSpell:ignore Cachix devenv -->

## 🧑🏻‍💻 Usage

Add `devenv-recipes` input to `devenv.yaml`:

```yaml
# devenv.yaml
inputs:
  …
  devenv-recipes:
    url: github:biapy/devenv-recipes?dir=src
    flake: false
```

<!-- CSpell:ignore biapy -->

Update `devenv.lock`:

```bash
devenv update
```

Add the wished imports to `devenv.nix`, here for a Nix project:

```nix
# devenv.nix
{ inputs, ... }:
{
  imports = [
    "${inputs.devenv-recipes}/devenv-scripts.nix"
    "${inputs.devenv-recipes}/git.nix"
    "${inputs.devenv-recipes}/devcontainer.nix"
    "${inputs.devenv-recipes}/markdown.nix"
    "${inputs.devenv-recipes}/nix.nix"
    "${inputs.devenv-recipes}/gitleaks.nix"
  ];
  …
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
