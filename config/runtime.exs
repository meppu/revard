import Config

config :revard,
  bot_token: System.get_env("REVOLT_BOT_TOKEN"),
  revolt_websocket: System.get_env("REVOLT_WEBSOCKET", "wss://ws.revolt.chat"),
  revolt_api: System.get_env("REVOLT_API", "https://api.revolt.chat"),
  server_id: System.get_env("REVOLT_SERVER_ID"),
  mongo_url: System.get_env("MONGO_URL"),
  port: System.get_env("PORT", "8000")
