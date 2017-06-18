defmodule ElSoconos.Playlist do
  defstruct [title: "", uri: "", meta: ""]

@moduledoc ~S"""
A struct containing identifying information for a Sonos playlist in the local network

#### The Playlist struct contains the following fields. Your data will vary.
```elixir
    %ElSoconos.Playlist {
        uri: "S://DiskStation/music/playlists/test.m3u",
        title: "test.m3u"
    }
"""

  @doc false
  def from_python(s) do
    %ElSoconos.Playlist{
      title: to_string(elem(s, 0)),
      uri: to_string(elem(s, 1))
    }
  end
end
