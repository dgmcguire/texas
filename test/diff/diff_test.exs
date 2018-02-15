defmodule Texas.DiffTest do
  use ExUnit.Case

  test "add div to empty child" do
    data_attr = :chat
    cached = {"div", [{"method", "POST"}, {"action", "/messages"}], []}
    new = {"div", [{"method", "POST"}, {"action", "/messages"}], [{"div", [], ["another"]}]}

    patch = Texas.Diff.diff(data_attr, cached, new)
    assert patch ==
      %{chat: %{children: [
          %{add: %{data: [["div", [], ["another"]]]} }
        ]}
      }
  end

  test "add div to non-empty child" do
    data_attr = :chat
    cached = {"div", [{"method", "POST"}, {"action", "/messages"}], [{"div", [], ["another"]}]}
    new = {"div", [{"method", "POST"}, {"action", "/messages"}], [{"div", [], ["another"]}, {"div", [], ["yet another"]}]}

    patch = Texas.Diff.diff(data_attr, cached, new)
    assert patch ==
      %{chat: %{children: [
        %{eq: 1},
        %{add: %{data: [["div", [], ["yet another"]]]}}
      ]}}
  end

  test "adds attr to root" do
    data_attr = :chat
    cached = {"div", [], []}
    new = {"div", [{"class", "add"}], []}

    patch = Texas.Diff.diff(data_attr, cached, new)
    assert patch == %{chat: %{attrs: [[:add, %{"class" => "add"}]]}}
  end

  test "deletes attr from root" do
    data_attr = :chat
    cached = {"div", [{"class", "some"}], []}
    new = {"div", [], []}

    patch = Texas.Diff.diff(data_attr, cached, new)
    assert patch == %{chat: %{attrs: [[:del, %{"class" => "some"}]]}}
  end

  test "updates attrs to root" do
    data_attr = :chat
    cached = {"div", [{"class", "on"}], []}
    new = {"div", [{"class", "off"}], []}

    patch = Texas.Diff.diff(data_attr, cached, new)
    assert patch == %{chat: %{attrs: [[:del, %{"class" => "on"}], [:add, %{"class" => "off"}]]}}
  end
end
