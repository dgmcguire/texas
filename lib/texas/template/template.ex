defmodule Texas.Template do
  @html5_attr "data-texas"
  @tlk "texas" # top level key

  def transform(html) do
    tree_walk(html, nil)
  end

  defp tree_walk([], _texas_id), do: []
  defp tree_walk(string, texas_id) when is_binary(string) do
    case texas_id do
      :none -> string
      _ -> []
    end
  end
  defp tree_walk([child|rest], texas_id) do
    [tree_walk(child, texas_id)|tree_walk(rest, texas_id)] |> List.flatten
  end
  defp tree_walk({tag,attrs,child} = element, _texas_id) when is_tuple(element) do
    case get_prop(element) do
      :none -> {tag,attrs,tree_walk(child, :none)}
      texas_id -> transform_element({tag,attrs,tree_walk(child, texas_id)}, texas_id)
    end
  end
  defp get_prop({_,attrs,_}) do
    {_, texas_id} = List.keyfind(attrs, @html5_attr, 0, {nil, :none})
    if texas_id, do: texas_id, else: :none
  end

  defp transform_element({tag,static_attrs,old_child}, texas_id) do
    attrs = [List.wrap(static_to_eex(static_attrs, texas_id)) | List.wrap(dyn_eex_expr(static_attrs, texas_id))] |> List.flatten
    child = dyn_content_expr(texas_id)
    old_child = if is_binary(old_child), do: [], else: old_child
    {tag, attrs, [child|List.wrap(old_child)]}
  end

  defp static_to_eex(static_attrs, texas_id) do
    Enum.map(static_attrs, fn {prop, vals} ->
      if prop == @html5_attr do
        {prop, vals}
      else
        {prop, "#{vals}#{static_eex_expr(prop, texas_id)}"}
      end
    end)
  end

  defp static_eex_expr(prop, texas_id) do
    dyn_attrs = "elem(#{@tlk}.#{texas_id}, 1)"
    ~s/<%= #{__MODULE__}.static_eex_attrs("#{prop}", #{dyn_attrs}) %>/
  end

  def static_eex_attrs(prop, dyn_attrs) do
    match = List.keyfind(dyn_attrs, prop, 0)
    if match, do: " #{elem(match, 1)}"
  end

  defp dyn_eex_expr(static_attrs, texas_id) do
    dyn_attrs = "elem(#{@tlk}.#{texas_id}, 1)"
    ~s/<%= #{__MODULE__}.outer_dyn_attrs(#{inspect(static_attrs)}, #{dyn_attrs}) %>/
  end

  defp dyn_content_expr(texas_id) do
    ~s/<%= for content <- elem(#{@tlk}.#{texas_id}, 2), do: #{__MODULE__}.render_node(content) %>/
  end

  def render_node(content) when is_binary(content), do: content
  def render_node(content) when is_tuple(content), do: content |> Floki.raw_html
  def render_node(_content), do: nil

  def outer_dyn_attrs(_static, []), do: nil
  def outer_dyn_attrs(static, dyn) do
    static
    |> remove_texas
    |> remove_dyn(dyn)
    |> return_class_vals_pairs
  end
  defp remove_texas(static), do: List.keydelete(static, "data-texas", 0)
  defp remove_dyn(static, dyn) do
    Enum.reject(dyn, fn {prop,_} -> List.keyfind(static, prop, 0) end)
  end
  defp return_class_vals_pairs(dyn_attrs) do
    Enum.map(dyn_attrs, fn {prop,vals} -> ~s/#{prop}="#{vals}"/ end)
     |> Enum.join(" ")
  end

  def render(eex_html, data) do
    EEx.eval_string(eex_html, data)
  end
end
