defmodule Texas.Channel do
  use Phoenix.Channel

  def join("texas:main", message, socket) do
    {:ok, socket}
  end

  #defp extract_uuid(message) do
    #%{"cookies" => cookies} = message
    #cookies = cookie_to_querystring(cookies)
    #%{"texas_uuid" => uuid} = URI.decode_query(cookies)
    #uuid
  #end

  #defp cookie_to_querystring(cookies) do
    #cookies
    #|> String.replace("\s", "&")
    #|> String.replace(";", "")
  #end
end
