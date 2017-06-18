
defmodule ElSoconos.Worker do
  @moduledoc false
  use GenServer
  use Export.Python
  require Logger
  alias ElSoconos.Favorite
  alias ElSoconos.Playlist
  alias ElSoconos.Group
  alias ElSoconos.Worker

  def start_link() do
    python_dir = :code.priv_dir(:el_soconos) ++ '/python/'
    python_instance = case Python.start(python_path: "#{python_dir}") do
      {:ok, p} ->
        p
      true ->
        nil
    end

    Logger.debug "starting ElSoconos Worker"
    GenServer.start_link(__MODULE__, %{instance: python_instance}, name: Worker)
  end

  def poll_network do
    GenServer.cast(Worker, :poll_network)
  end

  def network_state do
    GenServer.call(Worker, :network_state)
  end

  def favorites do
    GenServer.call(Worker, :favorites, 20_000)
  end

  def playlists do
    GenServer.call(Worker, :playlists, 20_000)
  end

  def speakers do
    GenServer.call(Worker, :speakers)
  end

  def groups do
    GenServer.call(Worker, :groups)
  end

  def get_favorite(uri) do
    case Enum.find(favorites(), fn(f) -> f.uri == uri end) do
      nil ->
        {:err, :not_found}
      fav ->
        {:ok, fav}
    end
  end

  def get_playlist(uri) do
    case Enum.find(playlists(), fn(f) -> f.uri == uri end) do
      nil ->
        {:err, :not_found}
      fav ->
        {:ok, fav}
    end
  end

  def get_speaker(uid) do
    case Enum.find(speakers(), fn(s) -> (s.uid == uid) || String.starts_with?(uid, s.uid) end) do
      nil ->
        {:err, :not_found}
      spk ->
        {:ok, spk}
    end

  end

  def get_group(uid) do
    case Enum.find(groups(), fn(s) -> (s.uid == uid) || String.starts_with?(uid, s.uid) end) do
      nil ->
        {:err, :not_found}
      grp ->
        {:ok, grp}
    end
  end

  def play(%Group{} = group, %Favorite{} = favorite) do
    GenServer.cast(Worker, {:play, group.coordinator_ip, favorite})
  end

  def play(%Group{} = group, %Playlist{} = playlist) do
    GenServer.cast(Worker, {:play, group.coordinator_ip, playlist})
  end

  def set_volume(spkr_uid, val) do
    case get_speaker(spkr_uid) do
      {:ok, spkr} ->
        GenServer.cast(Worker, {:set_volume, spkr.ip, val})
      _ ->
        Logger.warn "set volume failed with speaker #{inspect(spkr_uid)}"
    end
  end

  def set_group_volume(grp_uid, val) do
    case get_group(grp_uid) do
      {:ok, grp} ->
        GenServer.cast(Worker, {:set_group_volume, grp.coordinator_ip, val})
      _ ->
        Logger.warn "set group volume failed with speaker #{inspect(grp_uid)}"
    end
  end

  def stop(grp_uid) do
    case get_group(grp_uid) do
      {:ok, grp} ->
        GenServer.cast(Worker, {:stop, grp.coordinator_ip})
      _ ->
        Logger.warn "set group volume failed with speaker #{inspect(grp_uid)}"
    end
  end

  def add_to_group(spkr_uid, coord_uid) do
    with {:ok, spkr} <- get_speaker(spkr_uid),
         {:ok, grp} <- get_group(coord_uid)
    do
      GenServer.cast(Worker, {:add_to_group, spkr.ip, grp.coordinator_ip})
    else
      _ ->
        Logger.warn "Add group failed with speaker #{inspect(spkr_uid)} and coordinator #{inspect(coord_uid)}"
    end
  end

  def remove_from_group(spkr_uid) do
    case get_speaker(spkr_uid) do
      {:ok, spkr} ->
        GenServer.cast(Worker, {:remove_from_group, spkr.ip})
      _ ->
        Logger.warn "Remove from group failed with speaker #{inspect(spkr_uid)}"
    end
  end

  # server code
  def init(data) do
    {:ok, _} = Registry.register(ElSoconos, "el_soconos_update", [])
    {:ok, data}
  end

  def handle_call(:network_state, _from, data) do
    {:reply, data, data}
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
 
  def handle_cast({:play, ip, src}, data) do
    if not is_nil(data[:instance]) do
      data[:instance]
        |> Python.call(play_uri(ip, src.uri, src.meta), from_file: "controls")
    end
    {:noreply, data}
  end
  def handle_cast({:stop, ip}, data) do
    if not is_nil(data[:instance]) do
      data[:instance]
        |> Python.call(stop(ip), from_file: "controls")
    end
    {:noreply, data}
  end
  def handle_cast({:set_volume, ip, val}, data) do
    if not is_nil(data[:instance]) do
      data[:instance]
        |> Python.call(set_volume(ip, val), from_file: "controls")
    end
    {:noreply, data}
  end
  def handle_cast({:set_group_volume, ip, val}, data) do
    if not is_nil(data[:instance]) do
      data[:instance]
        |> Python.call(set_group_volume(ip, val), from_file: "controls")
    end
    {:noreply, data}
  end
  def handle_cast({:add_to_group, spkr_ip, coord_ip}, data) do
    if not is_nil(data[:instance]) do
      data[:instance]
        |> Python.call(add_to_group(spkr_ip, coord_ip), from_file: "controls")
    end  
    {:noreply, data}
  end
  def handle_cast({:remove_from_group, spkr_ip}, data) do
    if not is_nil(data[:instance]) do
      data[:instance]
      |> Python.call(remove_from_group(spkr_ip), from_file: "controls")
    end    
    {:noreply, data}
  end
  def handle_cast({:refresh_finished, msg}, state) do
    new_state = Map.merge(state, msg)

    if not Map.equal?(state, new_state) do
      GenServer.cast({:via, :gproc, {:p, :l, :pysonos_update}}, {:pysonos_update, new_state})
    end
    {:noreply, new_state}
  end
  def handle_cast(:poll_network, state) do
    ElSoconos.Flow.poll_network(state[:instance])
    {:noreply, state}
  end

  def handle_info({:el_soconos_update, data}, state) do
    {:noreply, Map.merge(state, data)}
  end

  def terminate(_reason, state) do
    Logger.debug "el_soconos crashing"
    Python.stop(state[:instance])
  end
end
