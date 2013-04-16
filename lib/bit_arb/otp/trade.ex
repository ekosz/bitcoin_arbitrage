defmodule BitArb.OTP.Trade do
  use GenServer.Behaviour
  require Lager

  import BitArb.Trade, only: [try_to_create_trade: 4, check_to_sell: 2]

  # Check every 30 secs
  @update_time 1000 * 30

  ### API

  def start_link(from, amount, to, sell_price) do
    :gen_server.start_link(__MODULE__, [from, amount, to, sell_price], [])
  end

  ### GenServer Callbacks

  def init([from, amount, to, sell_price]) do
    Lager.debug "#{from} -> #{to}: Trying to create trade"

    current_sell_price = BitArb.OTP.MtgoxPoller.price(to)[:sell]
    bank_response      = BitArb.OTP.Bank.buy_btc_from(from, amount: amount)

    case try_to_create_trade(to, current_sell_price, bank_response, sell_price) do
      {:ok, state} ->
        Lager.info "#{from} -> #{to}: Created Trade! State: #{inspect state}"
        self <- :check_to_sell
        {:ok, state}

      {:stop, reason} ->
        Lager.debug "#{from} -> #{to}: Could not create trade, #{reason}..."
        {:stop, :normal}
    end
  end

  def handle_info(:check_to_sell, state) do
    Lager.debug "Trade #{state.currency}: Checking to sell"
    current_sell_price = BitArb.OTP.MtgoxPoller.price(state.currency)[:sell]

    case check_to_sell(current_sell_price, state) do
      {:sell, :profit} ->
        Lager.info "Trade #{state.currency}: Selling for profit!"
        BitArb.OTP.Bank.sell_btc_to(state.currency, amount: state.amount_to_sell)
        {:stop, :normal, state}

      {:sell, :stop_loss} ->
        Lager.info "Trade #{state.currency}: Selling at loss..."
        BitArb.OTP.Bank.sell_btc_to(state.currency, amount: state.amount_to_sell)
        {:stop, :normal, state}

      :hold ->
        Lager.debug "Trade #{state.currency}: Could not find oppertunity to sell"
        {:ok, timer} = :timer.send_after(@update_time, :check_to_sell) # Loop
        {:noreply, state.timer(timer)}
    end
  end
end
