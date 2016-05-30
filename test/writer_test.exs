defmodule WriterTest do
  use ExUnit.Case, async: true
  alias Texas.ClientAction

  @expected """
  $("data-scope='post'").on("submit", function( event ) {
    event.preventDefault();
    channel.push("scope:post", {query: $(event.target).serialize()});
  });
  """

  test "provided args create expected js file" do
    path = "test-post.js"
    file = ClientAction.define("post", path)
    assert File.read!(file) |> String.strip == @expected |> String.strip

    #cleanup
    File.rm(path)
  end
end
