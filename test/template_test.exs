defmodule TemplateTest do
  use ExUnit.Case
  alias HelperFuncs, as: H
  alias Texas.Template

  @simple_elem "./test/fixtures/template/simple_element.html.tex"
  @simple_data [texas: %{ test: {"div", [], ["test content"]} }]
  @simple_elem_expected ~s(
    <div data-texas="test" >
      test content
    </div>
  ) |> H.whitespace_cleanup

  test "transforms simple elem" do
    output = H.transform(@simple_elem)
             |> Template.render(@simple_data)

    assert  output == @simple_elem_expected
  end

  @elem_w_attrs "./test/fixtures/template/elem_with_attrs.html.tex"
  @elem_w_attrs_data texas: %{test: {"div", [], ["test content"]}}
  @elem_w_attrs_expected ~s(
    <div data-texas="test" class="some attrs" id="more attrs" >
      test content
    </div>
  ) |> H.whitespace_cleanup

  test "transforms elem with attrs" do
    output = H.transform(@elem_w_attrs)
             |> Template.render(@elem_w_attrs_data)

    assert output == @elem_w_attrs_expected
  end

  @list_elem "./test/fixtures/template/list_elem.html.tex"
  @list_data texas: %{
    list: {"div", [], [{"div", [], ["first content"]}, {"div", [], ["second content"]}, {"div", [], ["third content"]}]}
  }
  @list_elem_expected ~s(
    <div data-texas="list" >
      <div>
        first content
      </div>
      <div>
        second content
      </div>
      <div>
        third content
      </div>
    </div>
  ) |> H.whitespace_cleanup

  test "transforms list elem" do
    output = H.transform(@list_elem)
             |> Template.render(@list_data)

    assert output == @list_elem_expected
  end

  @dyn_attrs "./test/fixtures/template/dyn_attrs.html.tex"
  @dyn_attrs_data texas: %{
    test: {"div", [{"class", "dynamic class adding"}, {"href", "www.example.com"}], ["content"]},
    nest: {"div", [{"class", "b"}, {"id", "c"}], ["more"]},
    nestb: {"div", [{"class", "b"}, {"id", "c"}], ["more"]}
  }
  @dyn_attrs_expected ~s(
    <div data-texas="test" class="some dynamic class adding" id="does this" href="www.example.com">
      content
      <div>
        <div data-texas="nest" class="a b" id="a b c" >
          more
        </div>
      </div>
      <div data-texas="nestb" class="a b" id="a b c" >
        more
      </div>
    </div>
  ) |> H.whitespace_cleanup

  test "dynamically add attributes" do
    output = H.transform(@dyn_attrs)
             |> IO.inspect(label: "testing")
             |> Template.render(@dyn_attrs_data)

    assert output == @dyn_attrs_expected
  end
end
