defmodule ExBanking do
  @moduledoc """
  Banking module for accounts and transfers management.
  """

  alias ExBanking.User

  @doc """
  Creates a new user.

  ## Examples

      iex> ExBanking.create_user("Alice")
      :ok

  """
  @spec create_user(user :: String.t()) :: :ok | {:error, :wrong_arguments | :user_already_exists}
  def create_user(user) when is_binary(user) do
    if is_valid_string?(user) do
      User.create(user)
    else
      {:error, :wrong_arguments}
    end
  end

  @doc """
  Deposit an amount for the given user

  ## Examples

      iex> ExBanking.create_user("Bob")
      iex> ExBanking.deposit("Bob", 100.00, "USD")
      {:ok, 100.00}

  """
  @spec deposit(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number}
          | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def deposit(user, amount, currency)
      when is_binary(user) and is_number(amount) and is_binary(currency) do
    if is_valid_string?(user) && is_valid_amount?(amount) && is_valid_string?(currency) do
      User.deposit(user, amount, currency)
    else
      {:error, :wrong_arguments}
    end
  end

  @doc """
  Withdraw an amount for the given user

  ## Examples

      iex> ExBanking.create_user("Carol")
      iex> ExBanking.deposit("Carol", 100.00, "USD")
      iex> ExBanking.withdraw("Carol", 100.00, "USD")
      {:ok, 0.0}

  """
  @spec withdraw(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number}
          | {:error,
             :wrong_arguments
             | :user_does_not_exist
             | :not_enough_money
             | :too_many_requests_to_user}
  def withdraw(user, amount, currency)
      when is_binary(user) and is_number(amount) and is_binary(currency) do
    if is_valid_string?(user) && is_valid_amount?(amount) && is_valid_string?(currency) do
      User.withdraw(user, amount, currency)
    else
      {:error, :wrong_arguments}
    end
  end

  @doc """
  Retrieve the balance for the given currency

  ## Examples

      iex> ExBanking.create_user("Dan")
      iex> ExBanking.deposit("Dan", 100.00, "USD")
      iex> ExBanking.get_balance("Dan", "USD")
      {:ok, 100.0}

  """
  @spec get_balance(user :: String.t(), currency :: String.t()) ::
          {:ok, balance :: number}
          | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def get_balance(user, currency) do
    if is_valid_string?(user) && is_valid_string?(currency) do
      User.get_balance(user, currency)
    else
      {:error, :wrong_arguments}
    end
  end

  @spec is_valid_string?(binary()) :: boolean()
  def is_valid_string?(value) when is_binary(value) do
    String.trim(value) != ""
  end

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
