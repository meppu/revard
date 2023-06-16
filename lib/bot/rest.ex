defmodule Revard.Bot.Rest do
  ### Exposed

  def user(id) do
    get("/users/" <> id)
  end

  def members() do
    server_id = Application.get_env(:revard, :server_id)

    case get("/servers/" <> server_id <> "/members") do
      {:ok, data} -> {:ok, Map.get(data, "users")}
      other -> other
    end
  end

  ### Internal

  defp get(path) do
    path
    |> build_request(:get)
    |> HTTPoison.request()
    |> case do
      {:ok, %{body: body}} -> Jason.decode(body)
      other -> other
    end
  end

  defp build_request(path, method),
    do: %HTTPoison.Request{
      method: method,
      url: Application.get_env(:revard, :revolt_api) <> path,
      headers: [{"x-bot-token", Application.get_env(:revard, :bot_token)}]
    }
end
