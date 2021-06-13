defmodule ExBanking.Validator do
  @moduledoc """
  Utility functions for type validation.

  ## Examples
      iex> import ExBanking.Validator
      iex> is_valid?("test")
      true
      iex> is_valid?("    ")
      false
      iex> is_valid?(123.222, 3)
      true
      iex> is_valid?(123, 3)
      true
      iex> is_valid?(123.222, 2)
      false
  """

  @doc "validates non empty string"
  @spec is_valid?(binary()) :: boolean()
  def is_valid?(value) when is_binary(value) do
    String.trim(value) != ""
  end

  @doc "validates float max precision"
  @spec is_valid?(number(), non_neg_integer()) :: boolean()
  def is_valid?(value, max_precision) when is_number(value) and is_integer(max_precision) do
    value >= 0 && has_max_precision?(value, max_precision)
  end

  defp has_max_precision?(number, max_precision) when is_float(number) do
    number
    |> to_string()
    |> String.split(".")
    |> List.last()
    |> String.length()
    |> Kernel.<=(max_precision)
  end

  defp has_max_precision?(_number, _max_precision), do: true
end
