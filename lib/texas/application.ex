defmodule Texas.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(Texas.Client.Supervisor, []),
      supervisor(Registry, [:unique, ClientRegistry])
    ]

    opts = [strategy: :one_for_one, name: Texas.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
