defmodule Revard.Task.Snapshot do
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
    :timer.send_interval(60000, :tick)
  end

  @impl true
  def handle_info(:tick, state) do
    snapshot = Revard.Cache.Users.get() |> Jason.encode!()
    File.write("snapshot.json", snapshot)

    {:noreply, state}
  end
end
