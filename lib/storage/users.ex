defmodule Revard.Storage.Users do
  @coll "users"

  def insert(data) when is_map(data), do: Mongo.insert_one(:mongo, @coll, data)
  def insert(users) when is_list(users), do: Mongo.insert_many(:mongo, @coll, users)

  def patch(id, data, clear_list) do
    # Remove ID Cache
    :ets.delete(:cache, id)

    Mongo.update_one(:mongo, @coll, %{_id: id}, %{"$set" => data})

    if length(clear_list) > 0 do
      clear_payload =
        clear_list
        |> Enum.reduce(%{}, fn value, acc ->
          case value do
            "ProfileContent" ->
              Map.put(acc, "profile.content", "")

            "ProfileBackground" ->
              Map.put(acc, "profile.background", "")

            "StatusText" ->
              Map.put(acc, "status.text", "")

            "Avatar" ->
              Map.put(acc, "avatar", "")

            _ ->
              acc
          end
        end)

      Mongo.update_one(:mongo, @coll, %{_id: id}, %{"$unset" => clear_payload})
    end
  end

  def remove(id) when is_binary(id), do: Mongo.delete_one(:mongo, @coll, %{_id: id})

  def get(id) when is_binary(id), do: Mongo.find(:mongo, @coll, %{_id: id}).docs
  def get(ids) when is_list(ids), do: Mongo.find(:mongo, @coll, %{_id: %{"$in": ids}}).docs

  def get, do: Mongo.find(:mongo, @coll, %{}).docs
end
