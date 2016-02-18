use Mix.Config

# In this file, we keep production configuration that
# you likely want to automate and keep it away from
# your version control system.
config :saints, Saints.Endpoint,
  http: [port: {:system, "PORT"}],
  url: [host: "elmsaints.herokuapp.com", port: 80],
  cache_static_manifest: "priv/static/manifest.json",
  secret_key_base: "jzN65YFAcSYUSCDuJYcuYwWAvAgyMWkKB3LzF6hX47JfpAFaK6xTHpHtwCpaP6j5M"

# Configure your database
config :saints, Saints.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "xsquthemutpsfc",
  password: "qPQxQYd-FJ-z80biF-xANqeUJj",
  database: "d4u6f4p21o7f50",
  pool_size: 20
