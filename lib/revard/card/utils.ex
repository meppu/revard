defmodule Revard.Card.Utils do
  @moduledoc """
  Card render utilities
  """

  def encode_string(value) do
    value
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
