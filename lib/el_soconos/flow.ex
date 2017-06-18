
defmodule ElSoconos.Flow do
  @moduledoc false
  use Export.Python
  require Logger

  def poll_network(inst) do
    Logger.debug "starting ElSoconos flow"
    spawn fn ->
      fetch_zones(inst)
      fetch_groups(inst)
      fetch_favorites(inst)
      fetch_playlists(inst)
    end
  end

  defp fetch_zones(inst) do
    spk = inst
      |> Python.call(get_speakers(), from_file: "zones")
      |> Enum.map(&ElSoconos.Speaker.from_python(&1))

    broadcast(%{speakers: spk})
  end

  defp fetch_groups(inst) do
    gps = inst
      |> Python.call(get_groups(), from_file: "zones")
      |> Enum.map(&ElSoconos.Group.from_python(&1))

    broadcast(%{groups: gps})
  end

  defp fetch_favorites(inst) do
    fav = inst
      |> Python.call(get_favorites(), from_file: "zones")
      |> Enum.map(&ElSoconos.Favorite.from_python(&1))

    broadcast(%{favorites: fav})
  end

  defp fetch_playlists(inst) do
    fav = inst
      |> Python.call(get_playlists(), from_file: "zones")
      |> Enum.map(&ElSoconos.Playlist.from_python(&1))

    broadcast(%{playlists: fav})
  end

  defp broadcast(data) do
    Registry.dispatch(ElSoconos, "el_soconos_update", fn entries ->
      for {pid, _} <- entries, do: send(pid, {:el_soconos_update, data})
    end)
  end
end
