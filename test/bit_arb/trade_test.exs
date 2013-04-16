Code.require_file "../../test_helper.exs", __FILE__

defmodule BitArb.TradeTest do
  use ExUnit.Case

  @currency          "USD"
  @buy_price         10
  @current_price     10
  @amount_btc_bought 10
  @sell_price        15
  @bank_response     {:ok, @buy_price, @amount_btc_bought}

  test "it correctly sets up state when there is a succsessful purchase from the bank" do
    assert {:ok, BitArb.Trade.State[currency: @currency, sell_price: @sell_price, amount_to_sell: @amount_btc_bought]} =
      BitArb.Trade.try_to_create_trade(@currency, @buy_price, @bank_response, @sell_price)

  end

  test "it sets the stop loss at 90% of the buy price" do
    assert {:ok, BitArb.Trade.State[stop_loss: 9.0]} =
      BitArb.Trade.try_to_create_trade(@currency, @current_price, @bank_response, @sell_price)
  end

  test "it stops with :insufficient_funds when there is :insufficient_funds" do
    bank_response = :insufficient_funds

    assert {:stop, :insufficient_funds} =
      BitArb.Trade.try_to_create_trade(@currency, @current_price, bank_response, @sell_price)
  end

  test "it sells with a profit when the currect price is equal to the sell price" do
    assert {:sell, :profit} =
      BitArb.Trade.check_to_sell(10, BitArb.Trade.State[sell_price: 10])
  end

  test "it sells with a profit when the currect price is larger than the sell price" do
    assert {:sell, :profit} =
      BitArb.Trade.check_to_sell(10, BitArb.Trade.State[sell_price: 9])
  end

  test "it sells with a loss when the currect price is equal to the stop loss" do
    assert {:sell, :stop_loss} =
      BitArb.Trade.check_to_sell(10, BitArb.Trade.State[stop_loss: 10])
  end

  test "it sells with a loss when the currect price is smaller than the stop loss" do
    assert {:sell, :stop_loss} =
      BitArb.Trade.check_to_sell(10, BitArb.Trade.State[stop_loss: 11])
  end

  test "it holds when the price is between the sell price and stop loss" do
    assert :hold =
      BitArb.Trade.check_to_sell(10, BitArb.Trade.State[stop_loss: 9, sell_price: 11])
  end
end
