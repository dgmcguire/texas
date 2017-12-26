defmodule Texas.TemplateEngine do
  import Phoenix.HTML.Engine
  import Phoenix.HTML
  import Floki

  def compile(template_path, _template_name\\nil) do
    html = template_path
      |> File.read!
      |> Floki.parse
      |> Texas.Template.transform
      |> Floki.raw_html

    Phoenix.HTML.safe_to_string({:safe, html})
      |> EEx.compile_string(engine: Phoenix.HTML.Engine, file: template_path, line: 1)
  end
end
