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
  - **tealdeer** (`tldr`): Fast implementation of tldr in Rust
  - **tokei**: Fast code statistics tool
  - **procs**: Modern replacement for ps
  - **bottom** (`btm`): Yet another cross-platform graphical process/system monitor
  - **duf**: Disk Usage/Free Utility with better UX than df

  ## 🛠️ Tech Stack

  - [ripgrep @ GitHub](https://github.com/BurntSushi/ripgrep)
  - [fd @ GitHub](https://github.com/sharkdp/fd)
  - [bat @ GitHub](https://github.com/sharkdp/bat)
  - [eza @ GitHub](https://github.com/eza-community/eza)
  - [zoxide @ GitHub](https://github.com/ajeetdsouza/zoxide)
  - [fzf @ GitHub](https://github.com/junegunn/fzf)
  - [tealdeer @ GitHub](https://github.com/dbrgn/tealdeer)
  - [tokei @ GitHub](https://github.com/XAMPPRocky/tokei)
  - [procs @ GitHub](https://github.com/dalance/procs)
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

  cfg = config.biapy-recipes.shell.modern-cli-tools;
in
{
  options.biapy-recipes.shell.modern-cli-tools = {
    enable = mkEnableOption "Modern CLI Tools";
  };

  config = mkIf cfg.enable {
    # https://devenv.sh/packages/
    packages = [
      pkgs.ripgrep # Fast grep alternative
      pkgs.fd # Fast find alternative
      pkgs.bat # Cat with syntax highlighting
      pkgs.eza # Modern ls replacement
      pkgs.zoxide # Smarter cd
      pkgs.fzf # Fuzzy finder
      pkgs.tealdeer # tldr client
      pkgs.tokei # Code statistics
      pkgs.procs # Modern ps
      pkgs.bottom # System monitor
      pkgs.duf # Better df
    ];

    enterShell = ''
      rg --version
      fd --version
      bat --version
      eza --version
      zoxide --version
      fzf --version
      tldr --version
      tokei --version
      procs --version
      btm --version
      duf --version
    '';
  };
}
