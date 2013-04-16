defmodule BitArb.OTP.TradeMaker do
  use GenServer.Behaviour
  require Lager

  # Update every 5 min
  @update_time 1000 * 60 * 5

  import BitArb.OTP.DirectionPredictor, only: [predict: 1]
  import BitArb.TradeMaker, only: [check_for_trade: 1, convert_from_usd: 2, calc_sell_price: 2]

  defrecord State, base: nil, test: nil, timer: nil

  ## API

  def start_link(base, test) do
    :gen_server.start_link(__MODULE__, [base, test], [])
  end

  ## GenServer callbacks

  def init([base, test]) do
    self <- :check_for_trade
    {:ok, State[base: base, test: test]}
  end

  def handle_info(:check_for_trade, State[base: base, test: test] = state) do
    Lager.debug "#{base} -> #{test}: Checking for trade"

    try do
      case check_for_trade( predict(from: base, to: test) ) do
        {:make_trade, amount_usd, sell_addition} ->
          Lager.debug "#{base} -> #{test}: Found trade!"
          create_trade(base, amount_usd, test, sell_addition)

        :no_trades ->
          Lager.debug "#{base} -> #{test}: Could not find trade"
          :ok
      end
    catch
      :price_not_ready ->
        Lager.debug "#{base} -> #{test} - Data from MtGox not ready yet."
        :ok

      {:data_too_old, _, _, diff} ->
        Lager.debug "#{base} -> #{test} - Data from MtGox was too old. differance: #{diff}"
        :ok
    end

    {:ok, timer} = :timer.send_after(@update_time, :check_for_trade) # Loop forever

    {:noreply, state.timer(timer)}
  end

  defp create_trade(from, amount_usd_to_purchase, to, sell_addition) do
    current_price = BitArb.OTP.MtgoxPoller.price(to)[:sell]

    sell_price = calc_sell_price(current_price, sell_addition)
    amount = convert_from_usd(amount_usd_to_purchase, BitArb.OTP.ExchangeRatePoller.rate(from))

    BitArb.OTP.TradeSup.create_trade(from, amount, to, sell_price)
  end

end
