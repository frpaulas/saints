use Mix.Config

# In this file, we keep production configuration that
# you likely want to automate and keep it away from
# your version control system.
config :saints, Saints.Endpoint,
  http: [port: {:system, "PORT"}],
  url: [host: "elmsaints.herokuapp.com", port: 80],
  cache_static_manifest: "priv/static/manifest.json",
  secret_key_base: "jsB28HwJpTyZwNY9bc9LyN6quE9LamXh8WHSgUvSLfXntAv4g4eLLMYzZZRUpEC72e8ahfKvUBrw", # System.get_env("SECRET_KEY_BASE")

# Configure your database
config :saints, Saints.Repo,
  adapter: Ecto.Adapters.Postgres,
  hostname: System.get_env("DB_HOSTNAME"),
  username: System.get_env("DB_USER"),
  password: System.get_env("DB_PASSWORD"),
  database: System.get_env("DB_NAME"),
  pool_size: 20
