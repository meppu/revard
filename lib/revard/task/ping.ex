defmodule Revard.Task.Ping do
  @moduledoc """
  This task send ping messages to Revolt's websocket for bot connectivity
  """

  use GenServer

  def child_spec([]) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      restart: :transient
    }
  end

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_args) do
    :timer.send_interval(25000, :tick)
  end

  @impl true
  def handle_info(:tick, state) do
    # Send Ping to Revolt
    WebSockex.send_frame(Revard.Bot.Listener, {:ping, <<69, 42, 00>>})

    # Check Pings
    # Since websock_adapter already does that, it is commented out.

    # Revard.Bucket.Consumers
    # |> Registry.select([{{:_, :"$1", :"$2"}, [], [{{:"$1", :"$2"}}]}])
    # |> Enum.filter(fn {_, data} ->
    #  DateTime.diff(DateTime.utc_now(), data.last_ping) > 60
    # end)
    # |> Enum.map(fn {pid, _} ->
    #   send(pid, :close)
    # end)

    {:noreply, state}
  end
end
