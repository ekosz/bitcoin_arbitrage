defmodule BitArb.OTP.Bank do
  use GenServer.Behaviour

  defrecord State, holdings: []

  import BitArb.Bank, only: [find_holding: 2, retrieve_amount_from_holding: 4,
                             put_amount_into_holding: 4, value_of_holdings: 2]

  ## API

  def start_link(name // __MODULE__, exchange_rate_poller // BitArb.OTP.ExchangeRatePoller) do
    :gen_server.start_link({:local, name}, __MODULE__, [exchange_rate_poller], [])
  end

  def holdings(name // __MODULE__) do
    :gen_server.call(name, :holdings)
  end

  def amount(symbol, name // __MODULE__) do
    :gen_server.call(name, {:amount, symbol})
  end

  def buy_btc_from(symbol, options, name // __MODULE__, mtgox_poller // BitArb.OTP.MtgoxPoller) do
    amount = Keyword.get options, :amount, 0
    :gen_server.call(name, {:buy_btc_from, symbol, amount, mtgox_poller})
  end

  def sell_btc_to(symbol, options, name // __MODULE__, mtgox_poller // BitArb.OTP.MtgoxPoller) do
    amount = Keyword.get options, :amount, 0
    :gen_server.call(name, {:sell_btc_to, symbol, amount, mtgox_poller})
  end

  def net_worth(name // __MODULE__, exchange_rate_poller // BitArb.OTP.ExchangeRatePoller)  do
    :gen_server.call(name, {:net_worth, exchange_rate_poller})
  end

  def stop(name // __MODULE__) do
    :gen_server.call(name, :stop)
  end

  ### GenServer Callbacks

  def init([exchange_rate_poller]) do
    default_holdings = Enum.map BitArb.traded_symbols, fn(symbol) ->
      {binary_to_atom(symbol), exchange_rate_poller.rate(symbol) * 1000}
    end

    {:ok, State[holdings: default_holdings]}
  end

  def handle_call(:holdings, _from, State[holdings: holdings] = state) do
    {:reply, holdings, state}
  end

  def handle_call({:amount, symbol}, _from, State[holdings: holdings] = state) do
    {:reply, find_holding(holdings, symbol), state}
  end

  def handle_call({:buy_btc_from, symbol, amount, mtgox_poller}, _from, State[holdings: holdings] = state) do
    buy_price = mtgox_poller.price(symbol)[:buy]

    {reply, new_holdings} = retrieve_amount_from_holding(holdings, symbol, buy_price, amount)

    {:reply, reply, state.holdings(new_holdings)}
  end

  def handle_call({:sell_btc_to, symbol, amount, mtgox_poller}, _from, State[holdings: holdings] = state) do
    sell_price = mtgox_poller.price(symbol)[:sell]

    {reply, new_holdings} = put_amount_into_holding(holdings, symbol, sell_price, amount)

    {:reply, reply, state.holdings(new_holdings)}
  end

  def handle_call({:net_worth, exchange_rate_poller}, _from, state) do
    amount = value_of_holdings(state.holdings, exchange_rate_poller.rates)
    {:reply, amount, state}
  end

  def handle_call(:stop, _from, state) do
    {:stop, :normal, :ok, state}
  end

end
