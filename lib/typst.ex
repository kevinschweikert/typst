defmodule Typst do
  @moduledoc """
  This module provides the core functions for interacting with
  the `typst` markup language compiler.

  Note that when using the formatting directives, they are exactly the same as
  `EEx`, so all of its constructs are supported.

  See [Typst's documentation](https://typst.app/docs) for a quickstart.
  """

  @embedded_fonts [Path.join(:code.priv_dir(:typst), "fonts")]

  @type formattable :: {atom, any}

  @spec render_to_string(String.t(), list(formattable)) :: String.t()

  @doc """
  Formats the given markup template with the given bindings, mostly
  useful for inspecting and debugging.

  ## Examples

      iex> Typst.render_to_string("= Hey <%= name %>!", name: "Jude")
      "= Hey Jude!"

  """

  def render_to_string(typst_markup, bindings \\ []) do
    EEx.eval_string(typst_markup, bindings)
  end

  @type typst_opt ::
          {:extra_fonts, list(String.t())}
          | {:root_dir, String.t()}
          | {:pixels_per_pt, number()}
          | {:assets, Keyword.t() | Map.t() | list({String.t(), binary()})}

  @spec render_to_pdf(String.t(), list(formattable()), list(typst_opt())) ::
          {:ok, binary()} | {:error, String.t()}
  @doc """
  Converts a given piece of typst markup to a PDF binary.

  ## Examples

      iex> {:ok, pdf} = Typst.render_to_pdf("= test\\n<%= name %>", name: "John")
      iex> is_binary(pdf)
      true

  """
  def render_to_pdf(typst_markup, bindings \\ [], opts \\ []) do
    extra_fonts = Keyword.get(opts, :extra_fonts, []) ++ @embedded_fonts
    root_dir = Keyword.get(opts, :root_dir, ".")

    assets =
      Keyword.get(opts, :assets, [])
      |> Enum.map(fn {key, val} -> {to_string(key), val} end)

    markup = render_to_string(typst_markup, bindings)

    Typst.NIF.compile_pdf(markup, root_dir, extra_fonts, assets)
  end

  @spec render_to_pdf!(String.t(), list(formattable()), list(typst_opt())) :: binary()
  @doc """
  Same as `render_to_pdf/3`, but raises if the rendering fails.
  """
  def render_to_pdf!(typst_markup, bindings \\ [], opts \\ []) do
    case render_to_pdf(typst_markup, bindings, opts) do
      {:ok, pdf} -> pdf
      {:error, reason} -> raise "could not build pdf: #{reason}"
    end
  end

  @spec render_to_png(String.t(), list(formattable()), list(typst_opt())) ::
          {:ok, list(binary())} | {:error, String.t()}
  @doc """
  Converts a given piece of typst markup to a PNG binary, one per each page.

  ## Examples

      iex> {:ok, pngs} = Typst.render_to_png("= test\\n<%= name %>", name: "John")
      iex> is_list(pngs)
      true

  """
  def render_to_png(typst_markup, bindings \\ [], opts \\ []) do
    extra_fonts = Keyword.get(opts, :extra_fonts, []) ++ @embedded_fonts
    root_dir = Keyword.get(opts, :root_dir, ".")
    pixels_per_pt = Keyword.get(opts, :pixels_per_pt, 1.0)

    assets =
      Keyword.get(opts, :assets, [])
      |> Enum.map(fn {key, val} -> {to_string(key), val} end)

    markup = render_to_string(typst_markup, bindings)

    Typst.NIF.compile_png(markup, root_dir, extra_fonts, pixels_per_pt, assets)
  end

  @spec render_to_png!(String.t(), list(formattable()), list(typst_opt())) :: list(binary())
  @doc """
  Same as `render_to_png/3`, but raises if the rendering fails.
  """
  def render_to_png!(typst_markup, bindings \\ [], opts \\ []) do
    case render_to_png(typst_markup, bindings, opts) do
      {:ok, png} -> png
      {:error, reason} -> raise "could not build png: #{reason}"
    end
  end
end
