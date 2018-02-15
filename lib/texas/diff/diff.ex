defmodule Texas.Diff do
  @moduledoc "Thin wrapper around myers diff to get a view patch"

  def diff(data_attr, cached, updated) do
    IO.inspect cached, label: "cached"
    IO.inspect updated, label: "updated"
    cached_attrs = elem(cached, 1)
    cached_children = elem(cached, 2)
    new_attrs = elem(updated, 1)
    new_children = elem(updated, 2)

    attrs_diff = diff_attrs(cached_attrs, new_attrs)
    child_diff = diff_children(cached_children, new_children)
    diff_map = Map.new([{:attrs, attrs_diff}, {:children, child_diff}])
               |> trim_empty

    diff =
      case {attrs_diff, child_diff} do
        {[], []} -> []
        _ -> Map.new([{data_attr, diff_map}])
      end
    {:ok, diff}
  end

  defp diff_attrs(cached, new) do
    List.myers_difference(cached, new)
    |> Enum.map(fn {op, attr} ->
      case op do
        :eq -> []
        :ins -> [:add, Enum.into(attr, %{})]
        :del -> [:del, Enum.into(attr, %{})]
      end
    end)
    |> trim_equal()
  end

  defp diff_children(cached, new) do
    List.myers_difference(cached, new)
    |> Enum.with_index()
    |> Enum.map(fn {x, index} ->
      case elem(x, 0) do
        :eq ->
          #[:eq, Enum.count(elem(x, 1)) - 1]
          %{eq: Enum.count(elem(x, 1))}

        :ins ->
          child = to_list(elem(x, 1))
          IO.inspect child, label: "child"
          %{add: %{data: child}}

        :del ->
          #[:del, index, Enum.count(elem(x, 1))]
          %{del: %{count: Enum.count(elem(x, 1))}}
      end
    end)
  end

  defp to_list([]), do: []
  defp to_list(str) when is_binary(str), do: str
  defp to_list([child|rest]), do: [to_list(child)|to_list(rest)]
  defp to_list({tag, attrs, [child|rest]}) do
    children = [to_list(child)|to_list(rest)]
    [tag, Enum.into(attrs, %{}), children]
  end

  defp trim_equal(patch) do
    eq_length = Enum.count(patch) == 1
    eq_elem = List.first(patch) == :eq

    case eq_length && eq_elem do
      true -> []
      _ -> patch
    end
  end

  defp trim_empty(patch) do
    Map.keys(patch)
    |> Enum.map(fn key ->
        case List.flatten(patch[key]) do
          [] -> Map.delete(patch, key)
          _ -> nil
        end
      end)
    |> Enum.filter(& !(&1 == nil))
    |> List.first
  end
end
