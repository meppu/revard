defmodule Revard.Bot.Rest do
  ### Exposed

  def user(id) do
    get("/users/" <> id)
    |> fetch_user_profile(id)
  end

  def members() do
    server_id = Application.get_env(:revard, :server_id)

    case get("/servers/" <> server_id <> "/members") do
      {:ok, data} -> {:ok, Map.get(data, "users")}
      other -> other
    end
  end

  ### Internal

  defp fetch_user_profile({:ok, data}, id) do
    if data["profile"] == nil do
      case get("/users/" <> id <> "/profile") do
        {:ok, value} -> {:ok, Map.put(data, "profile", value)}
        other -> other
      end
    else
      {:ok, data}
    end
  end

  defp fetch_user_profile(other, _id), do: other

  defp get(path) do
    path
    |> build_request(:get)
    |> Finch.request(Revard.Finch)
    |> case do
      {:ok, %Finch.Response{body: body}} -> Jason.decode(body)
      other -> other
    end
  end

  defp build_request(path, method) do
    url = Application.get_env(:revard, :revolt_api) <> path

    headers = [
      {"x-bot-token", Application.get_env(:revard, :bot_token)},
      {"content-type", "application/json;charset=UTF-8"}
    ]

    Finch.build(method, url, headers)
  end
end
