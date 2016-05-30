defmodule Texas.ClientAction do
  def define(scope, path \\ File.cwd!) do
    quoted = quote do
      {:ok, file} = File.open("#{unquote(path)}/#{unquote(scope)}.js", [:write])
      content =
        """
        $("data-scope='#{unquote(scope)}'").on("submit", function( event ) {
          event.preventDefault();
          channel.push("scope:#{unquote(scope)}", {query: $(event.target).serialize()});
        });
        """
      IO.binwrite file, content
      File.close file
    end
    Code.eval_quoted(quoted)
    path
  end
end
