defmodule BitArb.TradeMaker do
  # 0.6% fee on trades
  @trading_fee 0.006 * 2

  # Trade in $100 increments
  @trade_amount 100

  def check_for_trade({:rise, amount}) when (amount / 4) > @trading_fee do
    {:make_trade, @trade_amount * 2, (amount / 3)}
  end

  def check_for_trade({:rise, amount}) when (amount / 3) > @trading_fee do
    {:make_trade, @trade_amount, (amount / 3)}
  end

  def check_for_trade({_, _}) do
    :no_trades
  end

  def convert_from_usd(amount_usd, convertion) do
    amount_usd * convertion
  end

  def calc_sell_price(current_price, sell_addition) when sell_addition > 0 and sell_addition < 1 do
    current_price + (current_price * sell_addition)
  end
end
