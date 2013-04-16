defmodule BitArb.TradeMaker do
  @moduledoc """
  Provides the business logic when to create a trade
  """

  # 0.6% fee on trades
  @trading_fee 0.006 * 2

  # Trade in $100 increments
  @trade_amount 100

  @doc """
  It returns that a trade should be made when the currency is predicted
  to rise and it is rising at least 3 times more than the incurring
  trading fee. Depending on the safety of the trade (how much its
  predicting it will rise) it make suggest even more money should be
  put into the trade.

  If the currency is predicting to fall or if it is not rising enough,
  it will return :no_trades to be made.
  """
  def check_for_trade({:rise, amount}) when (amount / 4) > @trading_fee do
    {:make_trade, @trade_amount * 2, (amount / 3)}
  end

  def check_for_trade({:rise, amount}) when (amount / 3) > @trading_fee do
    {:make_trade, @trade_amount, (amount / 3)}
  end

  def check_for_trade({_, _}) do
    :no_trades
  end

  def convert_from_usd(amount_usd, conversion) do
    amount_usd * conversion
  end

  def calc_sell_price(current_price, sell_addition) when sell_addition > 0 and sell_addition < 1 do
    current_price + (current_price * sell_addition)
  end
end
