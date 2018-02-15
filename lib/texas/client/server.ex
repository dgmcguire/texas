defmodule Texas.Client.Server do
  use GenServer
  @pubsub Application.get_env(:texas, :pubsub)

  def start_link(_args, init_state, client_uid) do
    case Registry.lookup(ClientRegistry, client_uid) do
      [] -> GenServer.start_link(__MODULE__, [state: init_state, uid: client_uid])
      _ -> :already_started
    end
  end

  def init(opts) do
    Registry.register(ClientRegistry, opts[:uid], [])
    @pubsub.subscribe("texas:diff")
    {:ok, opts[:state]}
  end

  def handle_call({:get_state}, _from, state) do
    {:reply, state, state}
  end

  def handle_info(%{event: data_attr}, old_state) do
    data_attr = String.to_atom(data_attr)

    with %{view: view_module, data: view_data} <- old_state,
         {:ok, cached_fragment} <- Map.fetch(view_data, data_attr),
         new_fragment <- apply(view_module, data_attr, []),
         {:ok, diff} <- Texas.Diff.diff(data_attr, cached_fragment, new_fragment),
         new_state <- put_in(old_state[:data][data_attr], new_fragment)
    do
      @pubsub.broadcast("texas:main", "diff", diff)
      {:noreply, new_state}
    else
      _ ->
        {:noreply, old_state}
    end
  end

  def handle_info(_any, state), do: {:noreply, state}
end
