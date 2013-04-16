defmodule BitArb.OTP.ExchangeRatePoller do
  use GenServer.Behaviour

  # 1 hour in milliseconds
  @update_time 1000 * 60 * 60

  defrecord State, rates: [], timer: nil

  ### API

  def start_link do
    :gen_server.start_link({:local, __MODULE__}, __MODULE__, [], [])
  end

  def rate(symbol) do
    :gen_server.call(__MODULE__, {:rate, symbol})
  end

  def rates do
    :gen_server.call(__MODULE__, :rates)
  end

  ### OTP Callbacks

  def init([]) do
    {rates, timer} = update_rates
    {:ok, State[rates: rates, timer: timer]}
  end

  def handle_call(:rates, _from, State[rates: rates] = state) do
    {:reply, rates, state}
  end

  def handle_call({:rate, symbol}, _from, State[rates: rates] = state) do
    {:reply, get_rate(rates, symbol), state}
  end

  def handle_info(:update_rates, _state) do
    {rates, timer} = update_rates
    {:noreply, State[rates: rates, timer: timer]}
  end

  defp update_rates do
    rates = BitArb.ExchangeRateGetter.get_current
    {:ok, timer} = :timer.send_after(@update_time, :update_rates) # Loop forever
    {rates, timer}
  end

  defp get_rate(rates, symbol) when is_atom(symbol) do
    get_rate(rates, atom_to_binary(symbol))
  end

  defp get_rate(rates, symbol) when is_binary(symbol) do
    rates[symbol]
  end
end
