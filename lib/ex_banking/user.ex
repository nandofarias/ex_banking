defmodule ExBanking.User do
  use GenServer

  @max_process_message 10

  @spec create(user :: String.t()) :: :ok | {:error, :user_already_exists}
  def create(user) do
    case GenServer.start_link(__MODULE__, %{}, name: get_process_name(user)) do
      {:ok, _pid} ->
        :ok

      {:error, {:already_started, _pid}} ->
        {:error, :user_already_exists}
    end
  end

  @spec deposit(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number}
          | {:error, :user_does_not_exist | :too_many_requests_to_user}
  def deposit(user, amount, currency) do
    case GenServer.whereis(get_process_name(user)) do
      nil ->
        {:error, :user_does_not_exist}

      pid ->
        {:message_queue_len, mailbox_len} = Process.info(pid, :message_queue_len)

        if mailbox_len <= @max_process_message do
          GenServer.call(pid, {:deposit, amount, currency})
        else
          {:error, :too_many_requests_to_user}
        end
    end
  end

  @impl GenServer
  def init(balances) do
    {:ok, balances}
  end

  @impl GenServer
  def handle_call({:deposit, amount, currency}, _from, balances) do
    balance = Map.get(balances, currency, Decimal.new(0))
    {:ok, amount} = Decimal.cast(amount)
    new_balance = Decimal.add(balance, amount)
    {:reply, {:ok, Decimal.to_float(new_balance)}, Map.put(balances, currency, new_balance)}
  end

  defp get_process_name(user) do
    {:via, Registry, {ExBanking.UserRegistry, user}}
  end
end
