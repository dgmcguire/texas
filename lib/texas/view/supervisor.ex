defmodule Texas.CacheSupervisor do
  use DynamicSupervisor

  def start_link(arg) do
    DynamicSupervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def init(_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_cache({m,f,a}) do
    mfa = %{module: m, fun: f, args: a}
    DynamicSupervisor.start_child(__MODULE__, {Texas.Cache, mfa})
    |> IO.inspect label: "start cache"
  end
end
