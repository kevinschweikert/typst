defmodule Typst.Format do
  @moduledoc """
  Contains helper functions for converting elixir datatypes into 
  the format that Typst expects
  """

  defmodule Table do
    alias Typst.Format
    defstruct [:columns, :header, rows: []]

    defimpl String.Chars do
      def to_string(table) do
        """
        #table(
          columns: #{table.columns},
          table.header(#{Enum.map_join(table.header, ", ", &Format.content(&1))}),
          #{Format.table_content(table.rows)}
        )
        """
      end
    end
  end

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
  def table_content(columns) when is_list(columns) do
    Enum.map_join(columns, ",\n  ", fn row ->
      Enum.map_join(row, ", ", &format_column_element/1)
    end)
  end

  defp format_column_element(e) when is_integer(e) or is_binary(e), do: content(e)
  defp format_column_element(unknown), do: unknown |> inspect() |> content()

  def bold(el), do: "*#{el}*"
  def content(el), do: "[#{el}]"
end
