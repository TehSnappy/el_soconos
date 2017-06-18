defmodule ElSoconos do
  use Application
  require Logger
  alias ElSoconos.Favorite
  alias ElSoconos.Playlist
  alias ElSoconos.Group
  alias ElSoconos.Speaker
  alias ElSoconos.Worker

@moduledoc ~S"""
The gateway module for control of a Sonos system.

There is usually not any need to call any other functions. This code is a wrapper for the excellent [Python Soco library](http://docs.python-soco.com/en/latest/index.html)

### Querying the Sonos system
el_soconos reports on the Sonos network through elixir's Registry module, so an elixir later than version 1.4 is required.

Register for and receive these notifications like so:
```elixir
  {:ok, _} = Registry.register(ElSoconos, "el_soconos_update", [])

  def handle_info({:el_soconos_update, data}, state) do
    Map.merge(state, %{sonos: data})
  end
```
Initiate a data scan with the following code:
```elixir
  ElSoconos.poll_network
```

The data will be returned in a map with the following keys:
```elixir
  
{
    favorites: [
      %ElSoconos.Favorite{
        uri: "pndrradio:32399648508186355",
        title: "The Rolling Stones Radio",
        meta: <various data>
      }
    ],
    groups: [
      %ElSoconos.Group {
        uid: "RINCON_xxxxxxxxxxxxxxx:49",
        coordinator_ip: "10.0.1.64"
      }
    ],
    playlists: [
      %ElSoconos.Playlist{
        uri: "S://DiskStation/music/playlists/test.m3u",
        title: "test.m3u"
      }
    ],
    speakers: [
      %ElSoconos.Speaker{ 
        group_coordinator_ip: "10.0.1.64"
        group_uid: "RINCON_xxxxxxxxxxxxxxx:49"
        ip: "10.0.1.64"
        mode: "NORMAL"
        name: "Office"
        uid: "RINCON_xxxxxxxxxxxxxxx"
        volume: 30
      }
    ]
  }
```
You can query for the individual objects through the ElSoconos interface:
```elixir

  a_grp = ElSoconos.get_group(group_uid)
  a_fav = ElSoconos.get_favorite(favorite_uri)
  a_spkr = ElSoconos.get_speaker(speaker_uid)
```


### Controlling the Sonos system
Sources (either favorites or playlists) must be played through a group. Each speaker is in its own group it seems.

A single speaker cannot be used instead of a group, but the speaker struct contains a field group_uid, which can then be used to fetch the Group.

```elixir
  a_group = ElSoconos.get_group(a_speaker.group_uid)
  ElSoconos.play(a_group, a_favorite)
  ElSoconos.play(a_group, a_playlist)

  ElSoconos.set_volume(a_group, 70)
  ElSoconos.set_volume(a_speaker, 20)
```
  """

  @doc false
  def start(_type, _args) do
    Logger.info "starting ElSoconos app"
    ElSoconos.Supervisor.start_link
  end

@doc ~S"""
Starts a scan of the Sonos system.

The data will be received thourgh the el_soconos_update registry queue.
"""
  def poll_network do
    Worker.poll_network
  end

@doc ~S"""
returns the current Sonos network state.

This wil be in the form:
```elixir
  {
    favorites: [
      ElSoconos.Favorite, ...
    ],
    groups: [
      ElSoconos.Group, ...
    ],
    playlists: [
      ElSoconos.Playlist, ...
    ],
    speakers: [
      ElSoconos.Speaker, ...
    ]
  }
```
"""
  def network_state do
    Worker.network_state
  end

@doc ~S"""
returns an ElSoconos.Favorite given its uri.
"""
  def get_favorite(uri) do
    Worker.get_favorite(uri)
  end

@doc ~S"""
returns an ElSoconos.Speaker given its uid.
"""
  def get_speaker(uid) do
    Worker.get_speaker(uid)
  end

@doc ~S"""
returns an ElSoconos.Group given its uid.
"""
  def get_group(uid) do
    Worker.get_group(uid)
  end

@doc ~S"""
returns an ElSoconos.Playlist given its uri.
"""
  def get_playlist(uri) do
    Worker.get_playlist(uri)
  end

@doc ~S"""
Play the given Sonos favorite or playlist in the given group.
"""
def play(group, favorite_or_playlist)

  def play(%Group{} = group, %Favorite{} = favorite) do
    Worker.play(group, favorite)
  end

  def play(%Group{} = group, %Playlist{} = playlist) do
    Worker.play(group, playlist)
  end


  @doc ~S"""
  Stops playback in the group with the given uid.
  """
  def stop(%Group{uid: grp_uid}) do
    Worker.stop(grp_uid)
  end

  @doc ~S"""
  Add the given speaker to the given group.
  """
  def add_to_group(%Speaker{uid: spkr_uid}, %Group{uid: coord_uid}) do
    Worker.add_to_group(spkr_uid, coord_uid)
  end

  @doc ~S"""
  Remove the given speaker from its group.
  """
  def remove_from_group(%Speaker{uid: spkr_uid}) do
    Worker.remove_from_group(spkr_uid)
  end
  
  @doc ~S"""
  Set the volume of the given group or speaker scale of 0..100.
  """
  def set_volume(group_or_speaker, volume)
  def set_volume(%Group{uid: grp_uid}, val) do
    Worker.set_group_volume(grp_uid, val)
  end
  def set_volume(%Speaker{uid: spkr_uid}, val) do
    Worker.set_volume(spkr_uid, val)
  end
end
