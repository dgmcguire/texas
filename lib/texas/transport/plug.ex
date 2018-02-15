defmodule Texas.Plug do
  import Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    with nil <- conn.cookies["texas_uuid"]
    do
      put_resp_cookie(conn, "texas_uuid", UUID.uuid4(), [http_only: false])
    else
      _ -> conn
    end
  end
end
