defmodule Texas.Cache do
  #@moduledoc "processes for constructing an updated view for clients to diff against"
  #@pubsub Application.get_env(:texas, :pubsub)

  def start_link(mod, fun, args) do
    #mfa = {mod,fun,args}
    #IO.inspect "inside start_lnk"
    #case Registry.lookup(CacheRegistry, fun) do
      #[] -> GenServer.start_link(__MODULE__, [mod, fun, args])
      #_ -> :already_started
    #end
    {:ok, mod}
  end

  #def init({mod, fun, args} = mfa) do
    ##Registry.register(CacheRegistry, fun, [])
    #{:ok, mfa}
  #end

  #def handle_call(:update, _from, {mod, fun, args} = state) do
    #IO.inspect state, label: "state"
    #updated = apply(mod, fun, args)
    #@pubsub.broadcast("texas:diff:#{fun}", "view_update", updated)
    #{:reply, :ok, state}
  #end
end
