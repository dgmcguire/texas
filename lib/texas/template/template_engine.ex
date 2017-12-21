defmodule Texas.TemplateEngine do
  @moduledoc """
  This is the Phoenix.Template.Engine that allows Ratchet templates to be used with Phoenix.
  """
  @behaviour Phoenix.Template.Engine

  import Floki
  import Phoenix.HTML.Engine

  def compile(template_path, _template_name) do
      merged_html(template_path)
      |> EEx.compile_string(engine: Phoenix.HTML.Engine, file: template_path, line: 1)
  end

  def merged_html(template_path) do
    template_path
      |> File.read!
      |> Floki.parse
      #|> IO.inspect(label: "parsed")
      |> Texas.Template.transform
      #|> IO.inspect(label: "transformed")
      |> Floki.raw_html
  end
end
