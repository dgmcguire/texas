defmodule Texas.Controller do
  defmacro __using__(_opts) do
    quote do
      def texas_render(conn, template, assigns) do
        client_uid = conn.cookies["texas_uuid"]
        init_state = %{view: conn.private[:phoenix_view], data: assigns[:texas]}
        client_pid = {:via, Registry, {ClientRegistry, client_uid}}

        case Texas.Client.Supervisor.start_client(init_state, client_uid) do
          {:error, :already_started} ->
            GenServer.cast(client_pid, {:update_state, init_state})
          _ -> nil
        end
        Phoenix.Controller.render(conn, template, assigns)
      end
    end
  end
end
