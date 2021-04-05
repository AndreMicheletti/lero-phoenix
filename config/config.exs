# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :lero,
  ecto_repos: [Lero.Repo]

# Configures the endpoint
config :lero, LeroWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "kw9vmmYFOODwhgSgTWB6JbtwCAllGg/lg6ZJjhsFVIICFJqaWjVnuwUiC8P8Pg7R",
  render_errors: [view: LeroWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Lero.PubSub,
  live_view: [signing_salt: "X2WytdJ7"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
