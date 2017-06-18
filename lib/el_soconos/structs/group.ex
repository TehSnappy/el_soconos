defmodule ElSoconos.Group do
  defstruct uid: "", coordinator_ip: ""

@moduledoc ~S"""
A struct containing identifying information for a group of Sonos speakers in the local network

#### The Group struct contains the following fields. Your data will vary.
```elixir
    %ElSoconos.Group {
        uid: "RINCON_xxxxxxxxxxxxxxx:49",
        coordinator_ip: "10.0.1.64"
    }
"""


  @doc false
  def from_python(s) do
    %ElSoconos.Group{
      uid: elem(s, 0),
      coordinator_ip: to_string(elem(s, 1))
    }
  end
end
