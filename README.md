# el_soconos

An elixir package for controlling a Sonos sound system. This is a simple wrapper around the excellent [soco](http://python-soco.com) python package. el_soconos does not install this package, it assumes you have a working python installation and the SoCo library installed.

el_soconos is a work in progress. It is not a complete implementation of the Soco API, but rather has been filled out to perform a few simple functions. Feature requests will be accepted, pull requests will be welcomed.

Enjoy!

## Installation

Add el_soconos to your list of dependencies in mix.exs
```elixir
  def deps do
    [{:el_soconos, "~> 1.0.0"}]
  end
```

## Configuration
There is currently no configuration necessary for el_soconos.


## Usage
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

