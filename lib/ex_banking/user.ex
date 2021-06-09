defmodule ExBanking.User do
  use GenServer

  def create(user) do
    case GenServer.start_link(__MODULE__, [], name: get_process_name(user)) do
      {:ok, _pid} ->
        :ok

      {:error, {:already_started, _pid}} ->
        {:error, :user_already_exists}
    end
  end

  @impl GenServer
  def init(balances) do
    {:ok, balances}
  end

  defp get_process_name(user) do
    {:via, Registry, {ExBanking.UserRegistry, user}}
  end
end
