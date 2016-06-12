defmodule Texas.ClientAction do
  def define(prop) do
    quoted_client = client_send_back(prop)
    Code.eval_quoted(quoted_client)
    quoted_channel_sub = channel_sub(prop)
    Code.eval_quoted(quoted_channel_sub)
  end

  defp client_send_back(prop) do
    quote do
      path = "#{File.cwd!}/web/static/texas/"
      File.mkdir_p!(path)
      {:ok, file} = File.open(path <> "#{unquote(prop)}.js", [:write])
      content =
        """
        $("data-prop='#{unquote(prop)}'").on("submit", function( event ) {
          event.preventDefault();
          channel.push("prop:#{unquote(prop)}", {query: $(event.target).serialize()});
        });
        """
      IO.binwrite file, content
      File.close file
    end
  end

  defp channel_sub(prop) do
    path = "#{File.cwd!}/web/static/texas/"
    File.mkdir_p!(path)
    quote do
      {:ok, file} = File.open(path <> "#{unquote(prop)}.js", [:write])
      content =
        """
        var #{unquote(prop)}Html = document.querySelectorAll("[data-prop='#{unquote(prop)}']");
        channel.on('#{unquote(prop)}', function(message){
          var oldTree = convertHTML(#{unquote(prop)}Html.outerHTML);
          var newHtml = message.message.split("\n").join("").trim();
          var newTree = convertHTML(newHtml);
          var chageset = diff(oldTree, newTree);
          #{unquote(prop)}Html = patch(#{unquote(prop)}Html, changeset);
        """
      IO.binwrite file, content
      File.close file
    end
  end
end
