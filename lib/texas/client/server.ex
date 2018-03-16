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
    Registry.register(ClientRegistry, opts[:uid], [])

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

  def handle_call({:socket_info, client_socket}, from, state) do
    {:reply, :ok, Map.merge(state, %{client_socket: client_socket})}
  end

  def handle_info(%{event: "view_update", topic: <<topic::bytes-size(11), data_attr::binary>>} = event, old_state) do
    IO.inspect topic, label: "topic"
    IO.inspect event, label: "event"
    IO.inspect old_state, label: "old_state"
    data_attr = String.to_atom(data_attr)

    with %{view: view_module, data: view_data} <- old_state,
         {:ok, cached_fragment} <- Map.fetch(view_data, data_attr),
         new_fragment <- apply(view_module, data_attr, []),
         {:ok, diff} <- Texas.Diff.diff(data_attr, cached_fragment, new_fragment),
         new_state <- put_in(old_state[:data][data_attr], new_fragment)
    do
      IO.inspect "here"
      send(old_state.client_socket.channel_pid, {:diff, diff})
      {:noreply, new_state}
    else
      _ ->
        {:noreply, old_state}
    end
  end

  def handle_info(_any, state) do
    {:noreply, state}
  end
end
