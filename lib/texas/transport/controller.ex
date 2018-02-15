defmodule Texas.Controller do
  defmacro __using__(_opts) do
    quote do
      def texas_render(conn, template, assigns) do
        client_uid = conn.cookies["texas_uuid"]
        init_state = %{view: conn.private[:phoenix_view], data: assigns[:texas]}

        Texas.Client.Supervisor.start_client(init_state, client_uid)
        Phoenix.Controller.render(conn, template, assigns)
      end
    end
  end
end
