defmodule Revard.Storage.Users.Utils do
  @moduledoc """
  Utilities for user storage
  """

  @doc """
  Get user avatar and background with given format
  """
  def get_user_images(user_data, {:url, {max_avatar_size, max_background_size}}) do
    {
      get_user_avatar(user_data, {:url, max_avatar_size}),
      get_user_background(user_data, {:url, max_background_size})
    }
  end

  def get_user_images(user_data, :base64) do
    {
      get_user_avatar(user_data, :base64),
      get_user_background(user_data, :base64)
    }
  end

  @doc """
  Get user avatar with given format
  """
  def get_user_avatar(
        %{"_id" => _user_id, "avatar" => %{"_id" => avatar_id}},
        {:url, max_size}
      ) do
    autumn = Application.get_env(:revard, :autumn_url)

    if max_size != nil do
      "#{autumn}/avatars/#{avatar_id}?max_side=#{max_size}"
    else
      "#{autumn}/avatars/#{avatar_id}"
    end
  end

  def get_user_avatar(%{"_id" => user_id}, {:url, _max_avatar_size}) do
    revolt_api = Application.get_env(:revard, :revolt_api)

    "#{revolt_api}/users/#{user_id}/default_avatar"
  end

  def get_user_avatar(_other, {:url, _max_avatar_size}) do
    "https://raw.githubusercontent.com/revoltchat/revite/2acb3aeb14e464d2173dca28ce009eadf35ecd12/src/components/common/assets/user.png"
  end

  def get_user_avatar(data, :base64) do
    url = get_user_avatar(data, {:url, 128})

    :get
    |> Finch.build(url)
    |> Finch.request(Revard.Finch)
    |> case do
      {:ok, %Finch.Response{body: image}} -> Base.encode64(image)
      _ -> ""
    end
  end

  @doc """
  Get user background with given format
  """
  def get_user_background(
        %{"_id" => _user_id, "profile" => %{"background" => %{"_id" => background_id}}},
        {:url, max_size}
      ) do
    autumn = Application.get_env(:revard, :autumn_url)

    if max_size != nil do
      "#{autumn}/backgrounds/#{background_id}?max_side=#{max_size}"
    else
      "#{autumn}/backgrounds/#{background_id}"
    end
  end

  def get_user_background(_other, {:url, _max_size}) do
    "https://invalid.meppu.boo/"
  end

  def get_user_background(data, :base64) do
    url = get_user_background(data, {:url, 400})

    :get
    |> Finch.build(url)
    |> Finch.request(Revard.Finch)
    |> case do
      {:ok, %Finch.Response{body: image}} -> Base.encode64(image)
      _ -> ""
    end
  end
end
