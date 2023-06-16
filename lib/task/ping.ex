defmodule Revard.Task.Ping do
  use GenServer

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
    :timer.send_interval(30000, :tick)
  end

  @impl true
  def handle_info(:tick, state) do
    Bucket.Consumers
    |> Registry.select([{{:_, :"$1", :"$2"}, [], [{{:"$1", :"$2"}}]}])
    |> Enum.filter(fn {_, data} ->
      DateTime.diff(DateTime.utc_now(), data.last_ping) > 30
    end)
    |> Enum.map(fn {pid, _} ->
      send(pid, :close)
    end)

    {:noreply, state}
  end
end
