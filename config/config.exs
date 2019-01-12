# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :nostrum,
  token: System.get_env("DORAEMON_DISCORD_BOT"),
  num_shards: :auto

config :giphy,
  api_key: System.get_env("GIPHY")
