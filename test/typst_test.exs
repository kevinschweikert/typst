defmodule TypstTest do
  use ExUnit.Case

  test "smoke test" do
    assert "= Hello world" == Typst.render_to_string("= Hello <%= name %>", name: "world")

    {:ok, pdf} = Typst.render_to_pdf("= Hello <%= name %>", name: "world")
    assert is_binary(pdf)
  end

  test "table" do
    import Typst.Format

    table = %Typst.Format.Table{
      columns: 2,
      header: ["col1", "col2"],
      rows: [[bold("hello"), "world"], [bold("foo"), "bar"]]
    }

    expected = """
    #table(
      columns: 2,
      table.header([col1], [col2]),
      [*hello*], [world],
      [*foo*], [bar]
    )
    """

    assert expected == Typst.render_to_string("<%= table %>", table: table)
    {:ok, _pdf} = Typst.render_to_pdf("<%= table %>", table: table)
  end
end
