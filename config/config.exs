# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :meal_manager,
  ecto_repos: [MealManager.Repo],
  generators: [binary_id: false, timestamp_type: :utc_datetime_usec]

# Configures the endpoint
config :meal_manager, MealManagerWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: MealManagerWeb.ErrorHTML, json: MealManagerWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: MealManager.PubSub,
  live_view: [signing_salt: "FbSqdDan"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.2.7",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

config :langchain, :openai_key, fn -> System.fetch_env!("OPENAI_KEY") end

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
