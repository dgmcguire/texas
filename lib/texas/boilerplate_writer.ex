defmodule Texas.BoilerplateWriter do
  def metadata(scope, props) do
    props = List.wrap(props)
    master_file(scope, props) |> Code.eval_quoted
    socket_joins(scope, props) |> Code.eval_quoted
    import_dependencies_and_shit(scope, props) |> Code.eval_quoted
  end

  defp master_file(scope, props) do
    File.mkdir_p!("#{File.cwd!}/web/static/js/texas/")
    file_path = "#{File.cwd!}/web/static/js/texas/texas.js"
    {:ok, file} = File.open(file_path, [:write])
    import_list = for prop <- props, do: ~s(import "./#{prop}")
    content =
      """
      #{Enum.join(import_list, "\n")}
      """
    IO.binwrite file, content
    File.close file
  end

  defp import_dependencies_and_shit(scope, props) do
    for prop <- props do
      unless File.exists?("#{File.cwd!}/web/static/js/texas/#{prop}.js") do
        file_path = "#{File.cwd!}/web/static/js/texas/#{prop}.js"
        {:ok, file} = File.open(file_path, [:write])
        content =
          """
          #{import_sockets(props)}
          import $ from "jquery"
          import h from 'virtual-dom/h'
          import diff from 'virtual-dom/diff'
          import patch from 'virtual-dom/patch'
          import createElement from 'virtual-dom/create-element'
          import VNode from 'virtual-dom/vnode/vnode'
          import VText from 'virtual-dom/vnode/vtext'
          import htmlToVdom from 'html-to-vdom'

          #{init_bindings(prop)}
          #{vdom_stuff(scope, prop, props)}
          """
        IO.binwrite file, content
        File.close file
      end
    end
  end

  defp socket_joins(scope, props) do
    for prop <- props do
      unless File.exists?("#{File.cwd!}/web/static/js/texas/#{prop}_socket.js") do
        file_path = "#{File.cwd!}/web/static/js/texas/#{prop}_socket.js"
        {:ok, file} = File.open(file_path, [:write])
        content =
          """
          import socket from "../socket"
          let #{prop} = socket.channel("prop:#{prop}", {})
          #{prop}.join()
          export default #{prop}
          """
        IO.binwrite file, content
        File.close file
      end
    end
  end

  defp import_sockets(props) do
    content = for prop <- props do
      """
      import #{prop} from "./#{prop}_socket"
      """
    end
    content |> Enum.join |> String.trim_trailing
  end

  defp init_bindings(prop) do
    content = """
      $("[data-prop='#{prop}']").submit(function( event ) {
        event.preventDefault();
        #{prop}.push("prop:#{prop}", {query: $(event.target).serialize()});
      });
      """
  end

  defp vdom_stuff(scope, prop, props) do
    content =
    """
    var convertHTML = require('html-to-vdom')({ VNode: VNode, VText: VText });
    var #{scope}Html = $("[data-prop='#{scope}']")[0];
    #{prop}.on('prop:#{prop}', function(message){
      var oldTree = convertHTML(#{scope}Html.outerHTML);
      var newHtml = message.message.split("\\n").join("").trim();
      var newTree = convertHTML(newHtml);
      var changeset = diff(oldTree, newTree);
      #{scope}Html = patch(#{scope}Html, changeset);
      #{binding_resets(props)}
    });
    export default #{prop}
    """
  end
  defp binding_resets(props) do
    content = for prop <- props do
    """
      $("[data-prop='#{prop}']").unbind();
      $("[data-prop='#{prop}']").submit(function( event ) {
        event.preventDefault();
        #{prop}.push("prop:#{prop}", {query: $(event.target).serialize()});
      });
    """
    end
    content |> Enum.join |> String.trim
  end
end
