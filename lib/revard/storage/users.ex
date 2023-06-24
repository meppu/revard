defmodule Revard.Storage.Users do
  @moduledoc """
  User storage using MongoDB
  """

  @connection Revard.Mongo
  @coll "users"

  alias Revard.Storage.Cache

  @doc """
  Insert new user(s) to database
  """
  def insert(data) when is_map(data) do
    # Remove user from cache
    Cache.delete(data["_id"])

    Mongo.insert_one(@connection, @coll, data)
  end

  def insert(users) when is_list(users) do
    Mongo.insert_many(@connection, @coll, users)
  end

  @doc """
  Update user values
  """
  def patch(id, data, clear_list) do
    # Remove user from cache
    Cache.delete(id)

    Mongo.update_one(@connection, @coll, %{_id: id}, %{"$set" => data})

    # Clear given values from user
    if length(clear_list) > 0 do
      clear_payload =
        clear_list
        |> Enum.reduce(%{}, fn value, acc ->
          case value do
            "ProfileContent" -> Map.put(acc, "profile.content", "")
            "ProfileBackground" -> Map.put(acc, "profile.background", "")
            "StatusText" -> Map.put(acc, "status.text", "")
            "Avatar" -> Map.put(acc, "avatar", "")
            "DisplayName" -> Map.put(acc, "display_name", "")
            _ -> acc
          end
        end)

      Mongo.update_one(@connection, @coll, %{_id: id}, %{"$unset" => clear_payload})
    end
  end

  @doc """
  Remove user(s) from database
  """
  def remove(id) when is_binary(id) do
    Cache.delete(id)
    Mongo.delete_one(@connection, @coll, %{_id: id})
  end

  def remove(ids) when is_list(ids) do
    if length(ids) > 0 do
      ids
      |> Enum.each(&:ets.delete(:cache, &1))

      Mongo.delete_many(@connection, @coll, %{_id: %{"$in": ids}})
    end
  end

  @doc """
  Fetch user(s) from database
  """
  def get(id, method) when is_binary(id) do
    # Check if user exists in cache
    case Cache.get(id) do
      [{^id, value} | _other] ->
        case method do
          :user -> value.user
          _ -> value
        end

      _ ->
        # Fetch user and add to cache
        value = Mongo.find_one(@connection, @coll, %{_id: id})

        # Fetch user images and save as base64
        avatar_id =
          case value["avatar"] do
            %{"_id" => id} -> id
            _ -> nil
          end

        background_id =
          case value["profile"] do
            %{"background" => %{"_id" => id}} -> id
            _ -> nil
          end

        {avatar_base64, background_base64} = Revard.Card.Utils.image64(avatar_id, background_id)
        value = %{user: value, avatar: avatar_base64, background: background_base64}

        Cache.set(id, value)

        case method do
          :user -> value.user
          _ -> value
        end
    end
  end

  def get(ids) when is_list(ids) do
    Mongo.find(@connection, @coll, %{_id: %{"$in": ids}}).docs
  end

  def get() do
    Mongo.find(@connection, @coll, %{}).docs
  end
end
