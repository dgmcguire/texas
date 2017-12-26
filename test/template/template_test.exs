defmodule TemplateTest do
  use ExUnit.Case
  alias HelperFuncs, as: Helper
  import Phoenix.HTML

  @simple_elem "./test/fixtures/template/simple_element.html.tex"
  @simple_data [texas: %{ test: {"div", [], ["test content"]} }]
  @simple_elem_expected ~E"""
  <div data-texas="test" >
    test content
  </div>
  """
  test "transforms simple elem" do
    safe = Phoenix.HTML.safe_to_string(@simple_elem_expected)
    html_string = Helper.merged_eex(@simple_elem)

    defmodule Test do
      require EEx
      EEx.function_from_string(:def, :eval_html, html_string, [:assigns], [engine: Phoenix.HTML.Engine])
    end

    output = Test.eval_html(@simple_data)
      |> Phoenix.HTML.safe_to_string
    assert  output == safe
  end

  @elem_w_attrs "./test/fixtures/template/elem_with_attrs.html.tex"
  @elem_w_attrs_data [texas: %{test: {"div", [], ["test content"]}}]
  @elem_w_attrs_expected ~E"""
  <div data-texas="test" class="some attrs" id="more attrs" >
    test content
  </div>
  """

  test "transforms elem with attrs" do
    safe = Phoenix.HTML.safe_to_string(@elem_w_attrs_expected)
    html_string = Helper.merged_eex(@elem_w_attrs)

    defmodule Test do
      require EEx
      EEx.function_from_string(:def, :eval_html, html_string, [:assigns], [engine: Phoenix.HTML.Engine])
    end

    output = Test.eval_html(@simple_data)
      |> Phoenix.HTML.safe_to_string
    assert  output == safe
  end

  @list_elem "./test/fixtures/template/list_elem.html.tex"
  @list_data [texas: %{
    list: {"div", [],
      [
        {"div", [], ["first content"]},
        {"div", [], ["second content"]},
        {"div", [], ["third content"]}
      ]
    }
  }]
  @list_elem_expected  ~E"""
  <div data-texas="list" ><div>first content</div><div>second content</div><div>third content</div></div>
  """

  test "transforms list elem" do
    expected_output = Phoenix.HTML.safe_to_string(@list_elem_expected)
    html_string = Helper.merged_eex(@list_elem)

    defmodule Test do
      require EEx
      EEx.function_from_string(:def, :eval_html, html_string, [:assigns], [engine: Phoenix.HTML.Engine])
    end

    file_output = Test.eval_html(@list_data)
      |> Phoenix.HTML.safe_to_string
    assert  file_output == expected_output
  end

  @dyn_attrs "./test/fixtures/template/dyn_attrs.html.tex"
  @dyn_attrs_data texas: %{
    test: {"div", [{"class", "dynamic class adding"}, {"href", "www.example.com"}], ["content"]},
    nest: {"div", [{"class", "b"}, {"id", "c"}], ["more"]},
    nestb: {"div", [{"class", "b"}, {"id", "c"}], ["more"]}
  }
  @dyn_attrs_expected ~E"""
  <div data-texas="test" class="some dynamic class adding" id="does this" href="www.example.com">
    content
    <div>
      this should still be here
      <div data-texas="nest" class="a b" id="a b c" >
        more
      </div>
      put
    </div>
    <div data-texas="nestb" class="a b" id="a b c" >
      more
    </div>
  </div>
  """

  test "dynamically add attributes" do
    expected_output =
      Phoenix.HTML.safe_to_string(@dyn_attrs_expected)
      |> Helper.whitespace_cleanup
    html_string = Helper.merged_eex(@dyn_attrs)
    defmodule Test do
      require EEx
      EEx.function_from_string(:def, :eval_html, html_string, [:assigns], [engine: Phoenix.HTML.Engine])
    end
    file_output =
      Test.eval_html(@dyn_attrs_data)
      |> Phoenix.HTML.safe_to_string
      |> Helper.whitespace_cleanup

    assert  file_output == expected_output
  end
end
