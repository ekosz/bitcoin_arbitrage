defmodule BitArb.Trade do
  # 10% loss
  @stop_loss 0.9

  defrecord State, currency: nil, stop_loss: nil, sell_price: nil,
                   amount_to_sell: nil, timer: nil

  def try_to_create_trade(currency, current_price, {:ok, _buy_price, btc_amount}, sell_price) do
    stop_loss = current_price * @stop_loss
    {:ok, State[currency: currency, stop_loss: stop_loss,
                sell_price: sell_price, amount_to_sell: btc_amount]}
  end

  def try_to_create_trade(_, _, :insufficient_funds, _) do
    {:stop, :insufficient_funds}
  end

  def check_to_sell(current_price, State[sell_price: sp]) when current_price >= sp do
    {:sell, :profit}
  end

  def check_to_sell(current_price, State[stop_loss: sl]) when current_price <= sl do
    {:sell, :stop_loss}
  end

  def check_to_sell(_current_price, _state) do
    :hold
  end
end
