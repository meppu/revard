defmodule Revard.Card.Utils do
  @moduledoc """
  Card render utilities
  """

  @doc """
  Get user profile and background as base64
  """
  def image64(avatar, background) do
    avatar_encoded =
      avatar &&
        Finch.build(
          :get,
          Application.get_env(:revard, :autumn_url) <> "/avatars/" <> avatar <> "?max_side=64"
        )
        |> Finch.request(Revard.Finch)
        |> case do
          {:ok, %{body: avatar_raw}} -> Base.encode64(avatar_raw)
          _ -> nil
        end

    banner_encoded =
      background &&
        Finch.build(
          :get,
          Application.get_env(:revard, :autumn_url) <>
            "/backgrounds/" <> background <> "?max_side=400"
        )
        |> Finch.request(Revard.Finch)
        |> case do
          {:ok, %{body: background_raw}} -> Base.encode64(background_raw)
          _ -> nil
        end

    {avatar_encoded, banner_encoded}
  end

  def encode_string(value, max_length) do
    if String.length(value) > max_length do
      String.slice(value, 0..(max_length - 4)) <> "..."
    else
      value
    end
    |> String.to_charlist()
    |> Enum.map(&"&##{&1};")
    |> Enum.join()
  end

  def hex_color?(value) when is_binary(value) do
    Regex.match?(~r/^[0-9A-Fa-f]{6}$/, value)
  end

  def hex_color?(_other) do
    false
  end
end
