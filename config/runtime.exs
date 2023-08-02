import Config

config :revard,
  bot_token: System.get_env("REVOLT_BOT_TOKEN"),
  revolt_websocket: System.get_env("REVOLT_WEBSOCKET", "wss://app.revolt.chat/events"),
  revolt_api: System.get_env("REVOLT_API", "https://app.revolt.chat/api"),
  autumn_url: System.get_env("AUTUMN_URL", "https://autumn.revolt.chat"),
  server_id: System.get_env("REVOLT_SERVER_ID"),
  mongo_url: System.get_env("MONGO_URL"),
  port: System.get_env("PORT", "8000"),
  invite_url: System.get_env("REVOLT_SERVER_LINK")
