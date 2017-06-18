defmodule ElSoconos.Supervisor do
  @moduledoc false
  use Supervisor
  require Logger

  def start_link do
    Logger.debug "starting ElSoconos Supervisor"
    Supervisor.start_link(__MODULE__, :ok, name: ElSoconos.Supervisor)
  end


  def init(:ok) do
    children = [
      supervisor(Registry, [:duplicate, ElSoconos]),
      worker(ElSoconos.Worker, [])
    ]
    supervise(children, [strategy: :one_for_one])
  end
end