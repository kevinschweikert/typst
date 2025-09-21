defmodule TypstTest do
  use ExUnit.Case, async: true

  doctest Typst

  test "simple test" do
    assert "= Hello world" == Typst.render_to_string("= Hello <%= name %>", name: "world")

    {:ok, pdf} = Typst.render_to_pdf("= Hello <%= name %>", name: "world")
    assert <<37, 80, 68, 70, 45, _rest::binary>> = pdf

    {:ok, [png]} = Typst.render_to_png("= Hello <%= name %>", name: "world")
    assert <<137, 80, 78, 71, 13, 10, 26, 10, _rest::binary>> = png
  end
end
