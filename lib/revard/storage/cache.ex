defmodule Revard.Storage.Cache do
  @moduledoc """
  Cache storage for users
  """

  use GenServer

  ### Client

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Get value with key from cache
  """
  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  @doc """
  Append key-value to cache
  """
  def set(key, value) do
    GenServer.cast(__MODULE__, {:set, key, value})
  end

  @doc """
  Remove key from cache
  """
  def delete(key) do
    GenServer.cast(__MODULE__, {:delete, key})
  end

  ### Server

  @impl true
  def init(_args) do
    state = :ets.new(:user_cache, [:set, :private])
    {:ok, state}
  end

  @impl true
  def handle_call({:get, key}, _from, state) do
    {:reply, :ets.lookup(state, key), state}
  end

  @impl true
  def handle_cast({:set, key, value}, state) do
    :ets.insert(state, {key, value})
    {:noreply, state}
  end

  @impl true
  def handle_cast({:delete, key}, state) do
    :ets.delete(state, key)
    {:noreply, state}
  end
end
