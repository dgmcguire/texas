defmodule Texas.Cache do
  use GenServer
  @pubsub Application.get_env(:texas, :pubsub)

  def start_link(mfa) do
    GenServer.start_link(__MODULE__, mfa)
  end

  def init(mfa) do
    case Registry.lookup(CacheRegistry, mfa.fun) do
      [] ->
        Registry.register(CacheRegistry, mfa.fun, [])
        {:ok, mfa}
      _ ->
        :ignore
    end
  end

  def child_spec(mfa) do
    %{
      id: mfa.fun,
      start: {__MODULE__, :start_link, [mfa]}
    }
  end

  def handle_call(:update, _from, mfa) do
    %{module: mod, fun: fun, args: args} = mfa
    updated = apply(mod, fun, args)
    @pubsub.broadcast("texas:diff:#{fun}", "view_update", %{diff: updated})
    {:reply, :ok, mfa}
  end
end
