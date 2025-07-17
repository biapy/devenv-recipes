_: {
  scripts = {
    detr = {
      description = "Alias of devenv tasks run";
      exec = ''
        set -o 'errexit' -o 'nounset' -o 'pipefail'
        cd "$DEVENV_ROOT"
        devenv tasks run "$@"
      '';
    };
  };
}
