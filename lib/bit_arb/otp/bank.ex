defmodule BitArb.OTP.Bank do
  use GenServer.Behaviour

  defrecord State, holdings: []

  import BitArb.Bank, only: [find_holding: 2, retrieve_amount_from_holding: 4,
                             put_amount_into_holding: 4, value_of_holdings: 2]

  ## API

  def start_link do
    :gen_server.start_link({:local, __MODULE__}, __MODULE__, [], [])
  end

  def holdings do
    :gen_server.call(__MODULE__, :holdings)
  end

  def amount(symbol) do
    :gen_server.call(__MODULE__, {:amount, symbol})
  end

  def buy_btc_from(symbol, options) do
    amount = Keyword.get options, :amount, 0
    :gen_server.call(__MODULE__, {:buy_btc_from, symbol, amount})
  end

  def sell_btc_to(symbol, options) do
    amount = Keyword.get options, :amount, 0
    :gen_server.call(__MODULE__, {:sell_btc_to, symbol, amount})
  end

  def net_worth do
    :gen_server.call(__MODULE__, :net_worth)
  end

  ### GenServer Callbacks

  def init([]) do
    default_holdings = Enum.map BitArb.traded_symbols, fn(symbol) ->
      {binary_to_atom(symbol), BitArb.OTP.ExchangeRatePoller.rate(symbol) * 1000}
    end

    {:ok, State[holdings: default_holdings]}
  end

  def handle_call(:holdings, _from, State[holdings: holdings] = state) do
    {:reply, holdings, state}
  end

  def handle_call({:amount, symbol}, _from, State[holdings: holdings] = state) do
    {:reply, find_holding(holdings, symbol), state}
  end

  def handle_call({:buy_btc_from, symbol, amount}, _from, State[holdings: holdings] = state) do
    buy_price = BitArb.OTP.MtgoxPoller.price(symbol)[:buy]

    {reply, new_holdings} = retrieve_amount_from_holding(holdings, symbol, buy_price, amount)

    {:reply, reply, state.holdings(new_holdings)}
  end

  def handle_call({:sell_btc_to, symbol, amount}, _from, State[holdings: holdings] = state) do
    sell_price = BitArb.OTP.MtgoxPoller.price(symbol)[:sell]

    {reply, new_holdings} = put_amount_into_holding(holdings, symbol, sell_price, amount)

    {:reply, reply, state.holdings(new_holdings)}
  end

  def handle_call(:net_worth, _from, state) do
    amount = value_of_holdings(state.holdings, BitArb.OTP.ExchangeRatePoller.rates)
    {:reply, amount, state}
  end

end
