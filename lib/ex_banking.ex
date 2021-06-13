defmodule ExBanking do
  @moduledoc """
  Banking module for accounts and transfers management.
  """

  alias ExBanking.User
  import ExBanking.Validator

  @doc """
  Creates a new user.

  ## Examples

      iex> ExBanking.create_user("Alice")
      :ok

  """
  @spec create_user(user :: String.t()) :: :ok | {:error, :wrong_arguments | :user_already_exists}
  def create_user(user) when is_binary(user) do
    if is_valid?(user) do
      User.create(user)
    else
      {:error, :wrong_arguments}
    end
  end

  @doc """
  Deposit an amount for the given user

  ## Examples

      iex> ExBanking.create_user("Bob")
      :ok
      iex> ExBanking.deposit("Bob", 100.00, "USD")
      {:ok, 100.00}

  """
  @spec deposit(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number}
          | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def deposit(user, amount, currency)
      when is_binary(user) and is_number(amount) and is_binary(currency) do
    if is_valid?(user) && is_valid?(amount, 2) && is_valid?(currency) do
      User.deposit(user, amount, currency)
    else
      {:error, :wrong_arguments}
    end
  end
end
