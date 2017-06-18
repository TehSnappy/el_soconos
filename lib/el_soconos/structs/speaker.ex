defmodule ElSoconos.Speaker do
  defstruct [name: "", ip: "", volume: 0, uid: "", mode: "", group_uid: "", group_coordinator_ip: ""]

@moduledoc ~S"""
A struct contining identifying information for a Sonos speaker in the local network

#### The Speaker struct contains the following fields. Your data will vary.
```elixir
    %ElSoconos.Speaker {
        group_coordinator_ip: "10.0.1.64"
        group_uid: "RINCON_xxxxxxxxxxxxxxx:49"
        ip: "10.0.1.64"
        mode: "NORMAL"
        name: "Office"
        uid: "RINCON_xxxxxxxxxxxxxxx"
        volume: 30
    }
"""


  @doc false
  def from_python(s) do
    %ElSoconos.Speaker{
      name: to_string(elem(s, 0)),
      ip: to_string(elem(s, 1)),
      volume: elem(s, 2),
      uid: elem(s, 3),
      mode: elem(s, 4),
      group_uid: elem(s, 5),
      group_coordinator_ip: to_string(elem(s, 6))
    }
  end
end
