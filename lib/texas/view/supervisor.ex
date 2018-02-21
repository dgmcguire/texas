defmodule Texas.CacheSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_) do
    Supervisor.init([ Texas.Cache ], strategy: :simple_one_for_one)
  end

  def start_cache({m,f,a}) do
    IO.inspect m, label: "m"
    IO.inspect f, label: "f"
    IO.inspect a, label: "a am I here?"
    IO.inspect Supervisor.start_child(__MODULE__, [m,f,a]), label: "working?"
  end
end
