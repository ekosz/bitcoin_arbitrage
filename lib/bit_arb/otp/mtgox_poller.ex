defmodule BitArb.OTP.MtgoxPoller do
  use GenServer.Behaviour

  # 15 seconds in milliseconds
  @update_time 1000 * 15

  defrecord State, prices: [], timer: nil, timer_mod: nil, mtgox_getter: nil

  ### API

  def start_link(name // __MODULE__,
                 timer_mod // :timer,
                 mtgox_getter // BitArb.MtgoxGetter) do

    :gen_server.start_link({:local, name}, __MODULE__, [timer_mod, mtgox_getter], [])
  end

  def price(symbol, name // __MODULE__) do
    do_price(symbol, name)
  end

  defp do_price(symbol, name) when is_list(symbol) do
    do_price list_to_atom(symbol), name
  end

  defp do_price(symbol, name) when is_binary(symbol) do
    do_price binary_to_atom(symbol), name
  end

  defp do_price(symbol, name) when is_atom(symbol) do
    try do
      Keyword.get! prices(name), symbol
    rescue KeyError ->
      throw :price_not_ready
    end
  end

  def prices(name // __MODULE__) do
    :gen_server.call(name, :prices, 60_000) # Wait up to 1 min
  end

  def stop(name // __MODULE__) do
    :gen_server.call(name, :stop)
  end

  def state(name // __MODULE__) do
    :gen_server.call(name, :state)
  end

  ### OTP Callbacks

  def init([timer_mod, mtgox_getter]) do
    self <- :update_prices

    {:ok, State[timer_mod: timer_mod, mtgox_getter: mtgox_getter]}
  end

  def handle_call(:prices, _from, State[prices: prices] = state) do
    {:reply, prices, state}
  end

  def handle_call(:stop, _from, state) do
    {:stop, :normal, :ok, state}
  end

  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  def handle_info(:update_prices, state) do
    updated_prices = Enum.reduce BitArb.traded_symbols, state.prices, fn(symbol, prices) ->
      try do
        state.timer_mod.sleep 1000
        Keyword.put prices, binary_to_atom(symbol), state.mtgox_getter.btc_to(symbol)
      catch
        :empty_body -> prices
        :timeout -> prices
        :invalid_request_method -> prices
      end
    end

    state = state.prices(updated_prices)

    {:ok, next_timer} = state.timer_mod.send_after(@update_time, :update_prices) # Loop forever

    state = state.timer(next_timer)

    {:noreply, state}
  end

end
