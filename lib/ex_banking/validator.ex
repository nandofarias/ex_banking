defmodule ExBanking.Validator do
  @moduledoc """
  Utility functions for type validation.
  """

  @doc """
  Validates non empty string
  ## Examples
      iex> import ExBanking.Validator
      iex> is_valid_string?("test")
      true
      iex> is_valid_string?("    ")
      false
   
  """
  @spec is_valid_string?(binary()) :: boolean()
  def is_valid_string?(value) when is_binary(value) do
    String.trim(value) != ""
  end

  @doc """
  Validates amount
  ## Examples
      iex> import ExBanking.Validator
      iex> is_valid_amount?(123.22)
      true
      iex> is_valid_amount?(123)
      true
      iex> is_valid_amount?(123.222)
      false
   
  """
  @spec is_valid_amount?(number()) :: boolean()
  def is_valid_amount?(value) when is_number(value) do
    value >= 0 && has_max_precision?(value)
  end

  defp has_max_precision?(number) when is_float(number) do
    number
    |> to_string()
    |> String.split(".")
    |> List.last()
    |> String.length()
    |> Kernel.<=(2)
  end

  defp has_max_precision?(_number), do: true
end
