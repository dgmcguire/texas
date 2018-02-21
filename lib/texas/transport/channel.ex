defmodule Texas.Channel do
  use Phoenix.Channel

  def join("texas:main", %{"cookies" => cookies}, socket) do
    uuid = extract_uuid(cookies)
    socket = assign(socket, :texas_uuid, uuid)
    {:ok, socket}
  end

  def handle_in("main", %{"form_data" => payload}, socket) do
    %{"action" => action, "method" => method} = payload
    verb = String.to_atom(method)
    routes = TexasTestWeb.Router.__routes__()
    [route|_] = Enum.filter(routes, & &1.path == action && &1.verb == verb)
    apply(route.plug, route.opts, [socket, payload])
    {:reply, :ok, socket}
  end

  defp extract_uuid(cookies) do
    cookies = cookie_to_querystring(cookies)
    %{"texas_uuid" => uuid} = URI.decode_query(cookies)
    uuid
  end

  defp cookie_to_querystring(cookies) do
    cookies
    |> String.replace("\s", "&")
    |> String.replace(";", "")
  end
end
