defmodule Revard.Storage.Users do
  @connection Revard.Mongo
  @coll "users"

  alias Revard.Storage.Cache

  def insert(data) when is_map(data) do
    Cache.delete(data["_id"])
    Mongo.insert_one(@connection, @coll, data)
  end

  def insert(users) when is_list(users) do
    Mongo.insert_many(@connection, @coll, users)
  end

  def patch(id, data, clear_list) do
    Cache.delete(id)
    Mongo.update_one(@connection, @coll, %{_id: id}, %{"$set" => data})

    if length(clear_list) > 0 do
      clear_payload =
        clear_list
        |> Enum.reduce(%{}, fn value, acc ->
          case value do
            "ProfileContent" -> Map.put(acc, "profile.content", "")
            "ProfileBackground" -> Map.put(acc, "profile.background", "")
            "StatusText" -> Map.put(acc, "status.text", "")
            "Avatar" -> Map.put(acc, "avatar", "")
            _ -> acc
          end
        end)

      Mongo.update_one(@connection, @coll, %{_id: id}, %{"$unset" => clear_payload})
    end
  end

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

  def get(id) when is_binary(id) do
    case Cache.get(id) do
      [{^id, value} | _other] ->
        value

      _ ->
        value = Mongo.find_one(@connection, @coll, %{_id: id})
        Cache.set(id, value)

        value
    end
  end

  def get(ids) when is_list(ids) do
    Mongo.find(@connection, @coll, %{_id: %{"$in": ids}}).docs
  end

  def get() do
    Mongo.find(@connection, @coll, %{}).docs
  end
end
