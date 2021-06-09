defmodule ExBankingTest do
  use ExUnit.Case
  doctest ExBanking

  describe "create_user/1" do
    test "should create a user" do
      assert ExBanking.create_user(unique_user()) == :ok
    end

    test "should not create a user with an invalid name" do
      assert ExBanking.create_user(10) == {:error, :wrong_arguments}
      assert ExBanking.create_user("") == {:error, :wrong_arguments}
      assert ExBanking.create_user("    ") == {:error, :wrong_arguments}
    end

    test "should not create a user with the same name" do
      user = unique_user()
      :ok = ExBanking.create_user(user)

      assert ExBanking.create_user(user) == {:error, :user_already_exists}
    end
  end

  defp unique_user(user \\ "Alice") do
    "#{user}-#{System.unique_integer()}"
  end
end
