defmodule ExBankingTest do
  use ExUnit.Case, async: true
  doctest ExBanking
  doctest ExBanking.Validator

  describe "create_user/1" do
    test "should create a user" do
      assert ExBanking.create_user(unique_user()) == :ok
    end

    test "should not create a user with an invalid name" do
      assert ExBanking.create_user("") == {:error, :wrong_arguments}
      assert ExBanking.create_user("    ") == {:error, :wrong_arguments}
    end

    test "should not create a user with the same name" do
      user = unique_user()
      :ok = ExBanking.create_user(user)

      assert ExBanking.create_user(user) == {:error, :user_already_exists}
    end
  end

  describe "deposit/3" do
    test "should deposit an amount to the user with the given currency" do
      user = unique_user()
      :ok = ExBanking.create_user(user)

      assert ExBanking.deposit(user, 0.1, "USD") == {:ok, 0.1}
      assert ExBanking.deposit(user, 0.2, "USD") == {:ok, 0.3}
    end

    test "should not deposit with invalid values" do
      user = unique_user()
      :ok = ExBanking.create_user(user)

      assert ExBanking.deposit("", 200.00, "USD") == {:error, :wrong_arguments}
      assert ExBanking.deposit(user, 200.001, "USD") == {:error, :wrong_arguments}
      assert ExBanking.deposit(user, 200.00, "") == {:error, :wrong_arguments}
      assert ExBanking.deposit(user, 200.00, "    ") == {:error, :wrong_arguments}
    end

    test "should return an error when the user is not created" do
      user = unique_user()

      assert ExBanking.deposit(user, 200.00, "USD") == {:error, :user_does_not_exist}
    end

    test "should not allow more than 10 operations at the same time" do
      user = unique_user()
      :ok = ExBanking.create_user(user)

      pids = for _ <- 1..200, do: Task.async(fn -> ExBanking.deposit(user, 200.00, "USD") end)

      assert {:error, :too_many_requests_to_user} in Task.await_many(pids)
    end
  end

  defp unique_user(user \\ "Alice") do
    "#{user}-#{System.unique_integer()}"
  end
end
