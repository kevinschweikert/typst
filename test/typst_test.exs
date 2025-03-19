defmodule TypstTest do
  use ExUnit.Case

  doctest Typst.Format

  test "smoke test" do
    assert "= Hello world" == Typst.render_to_string("= Hello <%= name %>", name: "world")

    {:ok, pdf} = Typst.render_to_pdf("= Hello <%= name %>", name: "world")
    assert is_binary(pdf)
  end

  test "table" do
    import Typst.Format
    alias Typst.Format.Table
    alias Typst.Format.Table.{Hline, Header}

    table =
      %Table{
        columns: 2,
        content: [
          %Header{content: ["col1", "col2"], repeat: false},
          [bold("hello"), "world"],
          %Hline{start: 1},
          [bold("foo"), "bar"]
        ]
      }

    expected =
      "#table(columns: 2, table.header(repeat: false, [col1], [col2]), [*hello*], [world], table.hline(start: 1), [*foo*], [bar])"

    assert expected == Typst.render_to_string("<%= table %>", table: table)
    {:ok, pdf} = Typst.render_to_pdf("<%= table %>", table: table)
    File.write!("/Users/kevinschweikert/debug.pdf", pdf)
  end
end
