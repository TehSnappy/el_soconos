defmodule ElSoconos.State do
  use GenServer
  require Logger
  @moduledoc false

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: ElSoconos.State)
  end

  def get do
    GenServer.call(ElSoconos.State, :get_data)
  end

  def set(new_data) do
    GenServer.call(ElSoconos.State, {:set_data, new_data})
  end

  def favorites do
    GenServer.call(ElSoconos.State, :favorites, 20_000)
  end

  def playlists do
    GenServer.call(ElSoconos.State, :playlists, 20_000)
  end

  def speakers do
    GenServer.call(ElSoconos.State, :speakers)
  end

  def groups do
    GenServer.call(ElSoconos.State, :groups)
  end

  def init(data) do
    {:ok, _} = Registry.register(ElSoconos, "el_soconos_update", [])
    {:ok, data}
  end

  def handle_info({:el_soconos_update, data}, state) do
    {:noreply, Map.merge(state, data)}
  end

  def handle_call(:speakers, _from, data) do
    {:reply, data[:speakers], data}
  end
  def handle_call(:playlists, _from, data) do
    {:reply, data[:playlists], data}
  end
  def handle_call(:groups, _from, data) do
    {:reply, data[:groups], data}
  end
  def handle_call(:favorites, _from, data) do
    {:reply, data[:favorites], data}
  end
   def handle_call(:get_data, _from, data) do
    {:reply, data, data}
  end
  def handle_call({:set_data, new_data}, _from, _data) do
    {:reply, new_data, new_data}
  end
end
