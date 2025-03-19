defmodule Typst.Format do
  @moduledoc """
  Contains helper functions for converting elixir datatypes into 
  the format that Typst expects
  """

  @type column_data :: String.t() | integer

  @spec table_content(list(list(column_data))) :: String.t()
  @doc """
  Converts a series of columns mapped as a nested list to a format that can be 
  plugged in an existing table.

  ## Examples

      iex> columns = [["John", 10, 20], ["Alice", 20, 30]]
      iex> Typst.Format.table_content(columns)
      ~s/"John", "10", "20",\\n  "Alice", "20", "30"/
  """
  @deprecated "use %Typst.Format.Table{}"
  def table_content(columns) when is_list(columns) do
    Enum.map_join(columns, ",\n  ", fn row ->
      Enum.map_join(row, ", ", &format_column_element/1)
    end)
  end

  defp format_column_element(e) when is_integer(e) or is_binary(e), do: add_quotes(e)
  defp format_column_element(unknown), do: unknown |> inspect() |> add_quotes()

  defp add_quotes(s), do: "\"#{s}\""

  def bold(el), do: ["*", el, "*"] |> IO.iodata_to_binary()
  def content(el), do: ["[", el, "]"] |> IO.iodata_to_binary()
  def array(list) when is_list(list), do: (["("] ++ list ++ [")"]) |> IO.iodata_to_binary()

  @doc false
  def if_set(nil, _), do: []
  def if_set(_, content_fn) when is_function(content_fn), do: content_fn.()
  def if_set(_, content), do: content

  @doc false
  def recurse_list(content), do: do_recurse(content, ", ")

  defp do_recurse([], _separator), do: []
  defp do_recurse([elem], _separator), do: process(elem)

  defp do_recurse([elem | rest], separator) do
    [process(elem), separator | do_recurse(rest, separator)]
  end

  defp process(element) when is_list(element), do: do_recurse(element, ", ")
  defp process(element) when is_struct(element), do: to_string(element)
  defp process(element), do: content(element)

  def maybe_append_separator(list) when length(list) == 1, do: [list, ", "]
  def maybe_append_separator(list), do: list
end
