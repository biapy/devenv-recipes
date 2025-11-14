/**
  # Modern CLI Tools

  Collection of modern, user-friendly command-line tools that are replacements
  or enhancements for traditional UNIX utilities.

  ## 🧐 Features

  ### 📦 Included Tools

  - **ripgrep** (`rg`): Fast recursive grep with smart defaults
  - **fd**: Fast and user-friendly alternative to find
  - **bat**: Cat clone with syntax highlighting and Git integration
  - **eza**: Modern replacement for ls with Git integration
  - **zoxide**: Smarter cd command that learns your habits
  - **fzf**: Command-line fuzzy finder
  - **skim** (`sk`): Fuzzy finder in Rust, alternative to fzf
  - **tealdeer** (`tldr`): Fast implementation of tldr in Rust
  - **tokei**: Fast code statistics tool
  - **procs**: Modern replacement for ps
  - **btop**: Resource monitor with mouse support and game-like UI
  - **bottom** (`btm`): Yet another cross-platform graphical process/system monitor
  - **duf**: Disk Usage/Free Utility with better UX than df

  ## 🛠️ Tech Stack

  - [ripgrep @ GitHub](https://github.com/BurntSushi/ripgrep)
  - [fd @ GitHub](https://github.com/sharkdp/fd)
  - [bat @ GitHub](https://github.com/sharkdp/bat)
  - [eza @ GitHub](https://github.com/eza-community/eza)
  - [zoxide @ GitHub](https://github.com/ajeetdsouza/zoxide)
  - [fzf @ GitHub](https://github.com/junegunn/fzf)
  - [skim @ GitHub](https://github.com/lotabout/skim)
  - [tealdeer @ GitHub](https://github.com/dbrgn/tealdeer)
  - [tokei @ GitHub](https://github.com/XAMPPRocky/tokei)
  - [procs @ GitHub](https://github.com/dalance/procs)
  - [btop @ GitHub](https://github.com/aristocratos/btop)
  - [bottom @ GitHub](https://github.com/ClementTsang/bottom)
  - [duf @ GitHub](https://github.com/muesli/duf)
*/
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.biapy-recipes.shell.modern-cli;
in
{
  options.biapy-recipes.shell.modern-cli = {
    enable = mkEnableOption "Modern CLI Tools";
  };

  config = mkIf cfg.enable {
    # https://devenv.sh/packages/
    packages = with pkgs; [
      ripgrep # Fast grep alternative
      fd # Fast find alternative
      bat # Cat with syntax highlighting
      eza # Modern ls replacement
      zoxide # Smarter cd
      fzf # Fuzzy finder
      skim # Fuzzy finder (Rust)
      tealdeer # tldr client
      tokei # Code statistics
      procs # Modern ps
      btop # Resource monitor
      bottom # System monitor
      duf # Better df
    ];

    enterShell = ''
      rg --version
      fd --version
      bat --version
      eza --version
      zoxide --version
      fzf --version
      sk --version
      tldr --version
      tokei --version
      procs --version
      btop --version
      btm --version
      duf --version
    '';
  };
}
