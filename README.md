# devenv-recipes

Recipes for [Cachix devenv](https://devenv.sh/).

<!-- CSpell:ignore Cachix devenv -->

## 🧑🏻‍💻 Usage

Add `nixpkgs-unstable`, `landure/devenv-go-tasks`,
and `devenv-recipes` inputs to `devenv.yaml`:

```yaml
# devenv.yaml
inputs:
  …
  nixpkgs-unstable:
    url: github:nixos/nixpkgs/nixpkgs-unstable
  go-task:
    url: github:biapy/devenv-go-task?dir=modules/go-task
    flake: false
  biapy-recipes:
    url: github:biapy/devenv-recipes?dir=src
    flake: false

imports:
  - go-task
  - biapy-recipes
```

<!-- CSpell:ignore biapy nixpkgs nixos landure -->

Update `devenv.lock`:

```bash
devenv update
```

Enable the wished recipes in `devenv.nix`, here for a Nix project:

```nix
# devenv.nix
{inputs, ...}: {
  biapy.go-task.enable = true;
  biapy-recipes = {
    git.enable = true;
    nix.enable = true;
    markdown.enable = true;
    shell.enable = true;
    secrets.gitleaks.enable = true;
  };
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
