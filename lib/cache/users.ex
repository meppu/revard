defmodule Revard.Cache.Users do
  use GenServer

  ### Client

  def insert(data) when is_map(data), do: GenServer.cast(__MODULE__, {:insert, data})

  def patch(id, data, clear), do: GenServer.cast(__MODULE__, {:patch, id, data, clear})

  def remove(id) when is_binary(id), do: GenServer.cast(__MODULE__, {:remove, id})

  def get(id) when is_binary(id), do: GenServer.call(__MODULE__, {:get, [id]})
  def get(ids) when is_list(ids), do: GenServer.call(__MODULE__, {:get, ids})
  def get, do: GenServer.call(__MODULE__, {:get})

  ### Server Related

  def child_spec([]) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      restart: :transient
    }
  end

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_args) do
    case File.read("snapshot.json") do
      {:ok, snapshot} ->
        {:ok, Jason.decode!(snapshot)}

      _ ->
        case Revard.Bot.Rest.members() do
          {:ok, users} ->
            cache =
              users
              |> Enum.map(fn data -> {data["_id"], data} end)
              |> Map.new()

            {:ok, cache}

          _ ->
            {:stop, :fetch_error}
        end
    end
  end

  ### Calls and Casts

  @impl true
  def handle_cast({:insert, data}, state),
    do: {:noreply, Map.merge(state, %{data["_id"] => data})}

  @impl true
  def handle_cast({:patch, id, data, clear}, state) do
    new_state =
      state
      |> Map.get_and_update(id, fn value -> {value, Map.merge(value, data)} end)
      |> check_clear(id, clear)

    {:noreply, new_state}
  end

  @impl true
  def handle_cast({:remove, id}, state), do: {:noreply, Map.delete(state, id)}

  @impl true
  def handle_call({:get, ids}, _from, state) do
    values =
      ids
      |> Enum.map(&Map.get(state, &1))

    {:reply, values, state}
  end

  @impl true
  def handle_call({:get}, _from, state), do: {:reply, state, state}

  ### Internal
  ### TODO: Somehow make it better, following code is pretty shitty!

  defp check_clear({_, state}, id, clear_list),
    do:
      Enum.reduce(clear_list, state, fn elem, acc ->
        {_, new} = apply_clear(acc, id, elem)
        new
      end)

  defp apply_clear(state, id, "ProfileContent"),
    do:
      Map.get_and_update(state, id, fn outer ->
        {_, inner_result} =
          Map.get_and_update(outer, "profile", fn inner ->
            {inner, Map.delete(inner, "content")}
          end)

        {outer, inner_result}
      end)

  defp apply_clear(state, id, "ProfileBackground"),
    do:
      Map.get_and_update(state, id, fn outer ->
        {_, inner_result} =
          Map.get_and_update(outer, "profile", fn inner ->
            {inner, Map.delete(inner, "background")}
          end)

        {outer, inner_result}
      end)

  defp apply_clear(state, id, "StatusText"),
    do:
      Map.get_and_update(state, id, fn outer ->
        {_, inner_result} =
          Map.get_and_update(outer, "status", fn inner ->
            {inner, Map.delete(inner, "text")}
          end)

        {outer, inner_result}
      end)

  defp apply_clear(state, id, "Avatar"),
    do:
      Map.get_and_update(state, id, fn outer ->
        {outer, Map.delete(outer, "avatar")}
      end)

  defp apply_clear(state, _id, _other), do: state
end
