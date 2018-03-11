defmodule Texas.Client.Server do
  use GenServer
  @pubsub Application.get_env(:texas, :pubsub)

  def start_link(_args, init_state, client_uid) do
    IO.inspect client_uid, label: "client-Uid"
    case Registry.lookup(ClientRegistry, client_uid) do
      [] -> GenServer.start_link(__MODULE__, [state: init_state, uid: client_uid])
      _ -> :ignore
    end
  end

  def init(opts) do
    t = Registry.register(ClientRegistry, opts[:uid], [])
    IO.inspect opts[:uid], label: "opts"
    lookup = Registry.lookup(ClientRegistry, opts[:uid])
    IO.inspect lookup, label: "lookup"
    IO.inspect t, label: "t"

    ftest = state_view_builder_procs(opts)
    stest = sub_to_props(opts[:state])
    {:ok, opts[:state]}
  end

  defp state_view_builder_procs(view_state) do
    Enum.each(view_state[:state][:data], fn {k,v} ->
      Texas.CacheSupervisor.start_cache({view_state[:state][:view], k, []})
    end )
  end

  defp sub_to_props(state) do
    Enum.each(state[:data], fn {k,v} -> @pubsub.subscribe("texas:diff:#{k}") end)
  end

  def handle_call({:get_state}, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:update_state, state}, _state) do
    {:noreply, state}
  end

  def handle_info(event = %{event: "view_update"}, old_state) do
    IO.inspect event, label: "event"
    IO.inspect "HERE after broadcast"
    #data_attr = String.to_atom(data_attr)

    #with %{view: view_module, data: view_data} <- old_state,
         #{:ok, cached_fragment} <- Map.fetch(view_data, data_attr),
         #new_fragment <- apply(view_module, data_attr, []),
         #{:ok, diff} <- Texas.Diff.diff(data_attr, cached_fragment, new_fragment),
         #new_state <- put_in(old_state[:data][data_attr], new_fragment)
    #do
      #@pubsub.broadcast_from(self(), "texas:main", "diff", diff)
      #{:noreply, new_state}
    #else
      #_ ->
        #{:noreply, old_state}
    #end
  end

  def handle_info(_any, state) do
    {:noreply, state}
  end
end
