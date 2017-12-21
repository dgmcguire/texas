defmodule Texas.Diff do
  def diff([texas: old], [texas: new]) do
    keys = Map.keys(old)
    changed_keys = Enum.filter(keys, fn x -> !(new[x] == old[x]) end)
    for key <- changed_keys do
      [{key, new[key]}]
    end |> List.flatten
  end
end
