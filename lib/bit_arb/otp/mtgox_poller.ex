defmodule BitArb.OTP.MtgoxPoller do
  use GenServer.Behaviour

  # 15 seconds in milliseconds
  @update_time 1000 * 15

  defrecord State, prices: [], timer: nil

  ### API

  def start_link do
    :gen_server.start_link({:local, __MODULE__}, __MODULE__, [], [])
  end

  def price(symbol) when is_list(symbol) do
    price list_to_atom(symbol)
  end

  def price(symbol) when is_binary(symbol) do
    price binary_to_atom(symbol)
  end

  def price(symbol) when is_atom(symbol) do
    try do
      Keyword.get! prices(), symbol
    rescue KeyError ->
      throw :price_not_ready
    end
  end

  def prices do
    :gen_server.call(__MODULE__, :prices, 60_000) # Wait up to 1 min
  end

  ### OTP Callbacks

  def init([]) do
    self <- :update_prices

    {:ok, State[prices: []]}
  end

  def handle_call(:prices, _from, State[prices: prices] = state) do
    {:reply, prices, state}
  end

  def handle_info(:update_prices, state) do
    updated_prices = Enum.reduce BitArb.traded_symbols, state.prices, fn(symbol, prices) ->
      try do
        :timer.sleep 1000
        Keyword.put prices, binary_to_atom(symbol), BitArb.MtgoxGetter.btc_to(symbol)
      catch
        :empty_body -> prices
        :timeout -> prices
        :invalid_request_method -> prices
      end
    end

    {:ok, timer} = :timer.send_after(@update_time, :update_prices) # Loop forever

    {:noreply, State[prices: updated_prices, timer: timer]}
  end

end
