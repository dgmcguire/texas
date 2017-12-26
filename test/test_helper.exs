
defmodule HelperFuncs do
  import Phoenix.HTML
  ExUnit.start()

  def merged_eex(template_path) do
    html = template_path
      |> File.read!
      |> Floki.parse
      #|> IO.inspect(label: "parsed")
      |> Texas.Template.transform
      #|> IO.inspect(label: "transformed")
      |> Floki.raw_html

    escaped = ~E"""
    <%=raw(html)%>
    """
    Phoenix.HTML.safe_to_string(escaped)
  end

  def whitespace_cleanup(html_string) do
    html_string
      |> String.split("\n")
      |> Enum.map(&(String.trim(&1)))
      |> Enum.join
      |> String.trim
  end
end
