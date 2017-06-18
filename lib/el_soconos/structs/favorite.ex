defmodule ElSoconos.Favorite do
  defstruct [title: "", uri: "", meta: ""]

@moduledoc ~S"""
A struct containing identifying information for a Sonos favorite in the local Sonos network

#### The Favorite struct contains the following fields. Your data will vary.
```elixir
    %ElSoconos.Favorite {
        uri: "pndrradio:32399648508186355",
        title: "The Rolling Stones Radio",
        meta: <various data>
    }
"""

  @doc false
  def from_python(s) do
    %ElSoconos.Favorite{
      title: to_string(elem(s, 0)),
      uri: to_string(elem(s, 1)),
      meta: to_string(elem(s, 2))
    }
  end
end
