import Config

config :revard,
  bot_token: System.get_env("REVOLT_BOT_TOKEN"),
  revolt_websocket: System.get_env("REVOLT_WEBSOCKET", "wss://ws.revolt.chat")
