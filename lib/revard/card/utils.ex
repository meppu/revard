defmodule Revard.Card.Utils do
  @moduledoc """
  Card render utilities
  """

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
