defmodule Texas.TemplateEngine do
  @moduledoc """
  This is the Phoenix.Template.Engine that allows Ratchet templates to be used with Phoenix.
  """
  @behaviour Phoenix.Template.Engine

  import Floki
  import Phoenix.HTML.Engine

  def compile(template_path, _template_name) do
    template_path
      |> File.read!
      |> Floki.parse
      #|> IO.inspect(label: "parse")
      |> Texas.Template.transform
      #|> IO.inspect(label: "transfomr")
      |> Floki.raw_html
      #|> IO.inspect(label: "raw_html")
      |> EEx.compile_string(engine: Phoenix.HTML.Engine, file: template_path, line: 1)
      #|> IO.inspect(label: "compiled")
  end
end
