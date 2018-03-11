defmodule Texas.Cache do
  use GenServer
  #@moduledoc "processes for constructing an updated view for clients to diff against"
  #@pubsub Application.get_env(:texas, :pubsub)

  def start_link(mfa) do
    IO.inspect mfa, label: "inside cache with args"
    #mfa = {mod,fun,args}
    #IO.inspect "inside start_lnk"
    #case Registry.lookup(CacheRegistry, fun) do
      #[] -> GenServer.start_link(__MODULE__, [mod, fun, args])
      #_ -> :already_started
      #end
    GenServer.start_link(__MODULE__, [])
  end

  def child_spec(arg) do
    child_spec = %{
      id: arg.fun,
      start: {__MODULE__, :start_link, [arg]}
    } |> IO.inspect label: "child spec"
  end

  def handle_call(:update, _from, state) do
    IO.inspect state, label: "state"
    #updated = apply(mod, fun, args)
    #@pubsub.broadcast("texas:diff:#{fun}", "view_update", updated)
    {:reply, :ok, state}
  end
end
