defmodule Texas.Socket do
  defmacro __using__(opts) do
    quote do
      channel "texas:*", Texas.Channel
    end
  end
end
