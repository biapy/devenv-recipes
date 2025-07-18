_:

{
  # https://devenv.sh/integrations/dotenv/
  dotenv = {
    enable = true;
    filename = [
      ".env"
      ".env.dev"
      ".env.local"
    ];
  };
}
