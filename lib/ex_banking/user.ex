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
    with {:ok, pid} <- find_user_pid(user), do: execute(pid, {:deposit, amount, currency})
  end

  @spec withdraw(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number}
          | {:error,
             :user_does_not_exist
             | :not_enough_money
             | :too_many_requests_to_user}
  def withdraw(user, amount, currency) do
    with {:ok, pid} <- find_user_pid(user), do: execute(pid, {:withdraw, amount, currency})
  end

  @spec get_balance(user :: String.t(), currency :: String.t()) ::
          {:ok, balance :: number} | {:error, :user_does_not_exist | :too_many_requests_to_user}
  def get_balance(user, currency) do
    with {:ok, pid} <- find_user_pid(user), do: execute(pid, {:balance, currency})
  end

  @spec find_user_pid(binary()) :: {:ok, pid()} | {:error, :user_does_not_exist}
  defp find_user_pid(user) do
    case GenServer.whereis(get_process_name(user)) do
      nil ->
        {:error, :user_does_not_exist}

      pid ->
        {:ok, pid}
    end
  end

  @spec execute(pid(), tuple()) :: tuple() | {:error, :too_many_requests_to_user}
  defp execute(pid, instruction) do
    {:message_queue_len, mailbox_len} = Process.info(pid, :message_queue_len)

    if mailbox_len <= @max_process_message do
      GenServer.call(pid, instruction)
    else
      {:error, :too_many_requests_to_user}
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

  @impl GenServer
  def handle_call({:withdraw, amount, currency}, _from, balances) do
    balance = Map.get(balances, currency, Decimal.new(0))
    {:ok, amount} = Decimal.cast(amount)

    if Decimal.gt?(amount, balance) do
      {:reply, {:error, :not_enough_money}, balances}
    else
      new_balance = Decimal.sub(balance, amount)
      {:reply, {:ok, Decimal.to_float(new_balance)}, Map.put(balances, currency, new_balance)}
    end
  end

  @impl GenServer
  def handle_call({:balance, currency}, _from, balances) do
    balance = Map.get(balances, currency, Decimal.new(0))
    {:reply, {:ok, Decimal.to_float(balance)}, balances}
  end

  defp get_process_name(user) do
    {:via, Registry, {ExBanking.UserRegistry, user}}
  end
end
