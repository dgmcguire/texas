ExUnit.start()

defmodule HelperFuncs do
  def transform(path) do
    path
      |> File.read!
      |> Floki.parse
      |> IO.inspect( label: "parsed" )
      |> Texas.Template.transform
      |> IO.inspect( label: "transformed")
      |> Floki.raw_html
      |> IO.inspect(label: "raw html")
  end

  def whitespace_cleanup(html_string) do
    html_string
      |> String.split("\n")
      |> Enum.map(&(String.strip(&1)))
      |> Enum.join
      |> String.strip
  end
end
