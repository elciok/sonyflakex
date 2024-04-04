defmodule Sonyflakex.Config do
  @moduledoc """
  Configuration validation helpers
  """

  @doc """
  Sets default value for an option if option is not set
  in option list. Default value is set from a callback.

  Args:
    - opts: Configuration options.
    - option_name: Key for configuration option being validated.
    - default_callback: Function that returns a default value.
  """
  @spec set_default(keyword(), atom(), (-> any())) :: {:ok, keyword()}
  def set_default(opts, option_name, default_callback) do
    case Keyword.fetch(opts, option_name) do
      {:ok, _value} ->
        {:ok, opts}

      :error ->
        new_opts = Keyword.put(opts, option_name, default_callback.())
        {:ok, new_opts}
    end
  end

  @doc """
  Validates option value is an integer. This is checked only
  if value is set.
  """
  @spec validate_is_integer(keyword(), atom()) ::
          {:error, {:non_integer, atom(), any()}} | {:ok, keyword()}
  def validate_is_integer(opts, option_name) do
    case Keyword.fetch(opts, option_name) do
      {:ok, value} when is_integer(value) ->
        {:ok, opts}

      {:ok, value} ->
        {:error, {:non_integer, option_name, value}}

      :error ->
        {:ok, opts}
    end
  end

  @doc ~S"""
  Validates option value integer can be set as a binary
  in a field with a limited number of bits.

  Args:
    - opts: Configuration options
    - option_name: Key for configuration option being validated.
    - max_bits: Maximum number of bits that would fit the option value.
  """
  @spec validate_bit_option_length(keyword(), atom(), non_neg_integer()) ::
          {:error, {:value_too_big, atom(), integer()}} | {:ok, keyword()}
  def validate_bit_option_length(opts, option_name, max_bits) do
    case Keyword.fetch(opts, option_name) do
      {:ok, value} ->
        if value_fits_in_bits(value, max_bits) do
          {:ok, opts}
        else
          {:error, {:value_too_big, option_name, value}}
        end

      :error ->
        {:ok, opts}
    end
  end

  @doc ~S"""
  Checks if integer value binary representatino would fit in a number of bits.

  ## Examples

      iex> Sonyflakex.Config.value_fits_in_bits(255, 8)
      true

  """
  @spec value_fits_in_bits(integer(), non_neg_integer()) :: boolean()
  def value_fits_in_bits(value, length_bits) do
    <<max::integer-size(length_bits + 1)>> = <<1::size(1), 0::size(length_bits)>>
    value < max
  end
end
