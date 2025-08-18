/**
  # dotenv (`.env`)

  Dotenv is a zero-dependency module that loads environment variables from a
  `.env` file.
  Storing configuration in the environment separate from code is based on
  [3. Config @ The Twelve-Factor App](https://12factor.net/config).

  ## 🛠️ Tech Stack

  - [dotenv homepage](https://www.dotenv.org/).

  ## 🙇 Acknowledgements

  - [.env @ devenv](https://devenv.sh/integrations/dotenv/).
  - [dotenv @ devenv's reference](https://devenv.sh/reference/options/#dotenvenable).
*/
_: {
  dotenv = {
    enable = true;
    # filename = [
    #   ".env" # Default
    #   ".env.dev"
    #   ".env.local"
    # ];
  };
}
