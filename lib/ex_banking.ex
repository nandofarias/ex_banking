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
    if String.trim(user) != "" do
      User.create(user)
    else
      {:error, :wrong_arguments}
    end
  end

  def create_user(_user), do: {:error, :wrong_arguments}
end
