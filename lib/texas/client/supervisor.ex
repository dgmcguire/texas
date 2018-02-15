defmodule Texas.Client.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_) do
    Supervisor.init([ Texas.Client.Server ], strategy: :simple_one_for_one)
  end

  def start_client(init_state, client_uid) do
    Supervisor.start_child(__MODULE__, [init_state, client_uid])
  end
end
