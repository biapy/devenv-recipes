/**
  # SOPS utilities

  This module provides utilities for integrating SOPS with commands.

  - `wrapWithSopsExecEnv`: Wrap a command with `sops exec-env` to decrypt secrets.
*/
{ lib }:
{
  /**
    Wrap a command with `sops exec-env` to provide decrypted environment variables.

    When `sopsEnabled` is true, wraps the command with `sops exec-env "envFile" "command"`.
    When false, returns the command unchanged.

    # Example

    ```nix
    let
      sopsLib = import ./sops.nix { inherit lib; };
      tofuCommand = lib.meta.getExe opentofu;
      sopsCfg = config.biapy-recipes.secrets.sops;
    in {
      tofuExec = sopsLib.wrapWithSopsExecEnv {
        sopsEnabled = sopsCfg.enable;
        envFile = sopsCfg.terraform-env-file;
        command = "${tofuCommand} validate";
      };
    }
    ```

    # Type

    ```
    wrapWithSopsExecEnv :: { sopsEnabled: Bool, envFile: String, command: String } -> String
    ```

    # Arguments

    sopsEnabled
    : whether SOPS integration is enabled.

    envFile
    : path to the SOPS encrypted environment file.

    command
    : the command to wrap with sops exec-env.
  */
  wrapWithSopsExecEnv =
    {
      sopsEnabled,
      envFile,
      command,
    }:
    if sopsEnabled then ''sops exec-env "${envFile}" "${command}"'' else command;
}
