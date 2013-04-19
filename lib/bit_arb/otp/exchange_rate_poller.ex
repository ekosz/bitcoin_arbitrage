defmodule BitArb.OTP.ExchangeRatePoller do
  use GenServer.Behaviour

  # 1 hour in milliseconds
  @update_time 1000 * 60 * 60

  defrecord State, rates: [], timer: nil, timer_mod: nil, exchange_rater: nil

  ### API

  def start_link(name // __MODULE__,
                 timer // :timer,
                 exchange_rater // BitArb.ExchangeRateGetter) do

    :gen_server.start_link({:local, name}, __MODULE__, [timer, exchange_rater], [])
  end

  def rate(symbol, name // __MODULE__) do
    :gen_server.call(name, {:rate, symbol})
  end

  def rates(name // __MODULE__) do
    :gen_server.call(name, :rates)
  end

  def stop(name // __MODULE__) do
    :gen_server.call(name, :stop)
  end

  ### OTP Callbacks

  def init([timer_mod, exchange_rater]) do
    {rates, timer} = update_rates(timer_mod, exchange_rater)

    {:ok, State[rates: rates, timer: timer,
                timer_mod: timer_mod, exchange_rater: exchange_rater]}
  end

  def handle_call(:rates, _from, State[rates: rates] = state) do
    {:reply, rates, state}
  end

  def handle_call({:rate, symbol}, _from, State[rates: rates] = state) do
    {:reply, get_rate(rates, symbol), state}
  end

  def handle_call(:stop, _from, state) do
    {:stop, :normal, :ok, state}
  end

  def handle_info(:update_rates, state) do
    {rates, timer} = update_rates(state.timer_mod, state.exchange_rater)
    {:noreply, State[rates: rates, timer: timer]}
  end

  defp update_rates(timer_mod, exchange_rater) do
    rates = exchange_rater.get_current
    {:ok, timer} = timer_mod.send_after(@update_time, :update_rates) # Loop forever
    {rates, timer}
  end

  defp get_rate(rates, symbol) when is_atom(symbol) do
    get_rate(rates, atom_to_binary(symbol))
  end

  defp get_rate(rates, symbol) when is_binary(symbol) do
    rates[symbol]
  end
end
