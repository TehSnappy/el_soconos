defmodule ElSoconos.Artist do
  require Logger

  defstruct [title: "", uri: ""]

  @moduledoc ~S"""
  A struct containing identifying information for an Artist in the music library of the local Sonos network

  #### The Favorite struct contains the following fields. Your data will vary.
  ```elixir
      %ElSoconos.Artist {
          title: "Jimi Hendrix",
          uri: "rincon:32399648508186355",
      }
  """

  @doc false
  def from_python(s) do
    %ElSoconos.Artist{
      title: to_string(elem(s, 0)),
      uri: to_string(elem(s, 1))
    }
  end
end
