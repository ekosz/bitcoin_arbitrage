Code.require_file "../../test_helper.exs", __FILE__

defmodule BitArb.TradeMakerTest do
  use ExUnit.Case

  @safe_percentage    0.07
  @regular_percentage 0.04
  @unsafe_percentage  0.01

  test "it trades $200 when its a safer trade" do
    assert {:make_trade, 200, _sell_amount} =
      BitArb.TradeMaker.check_for_trade({:rise, @safe_percentage})
  end

  test "it sets the sell amount to one third of the current percentage" do
    assert {:make_trade, _, (@safe_percentage/3)} =
      BitArb.TradeMaker.check_for_trade({:rise, @safe_percentage})
  end

  test "it trades $100 when its a normal trade" do
    assert {:make_trade, 100, _sell_amount} =
      BitArb.TradeMaker.check_for_trade({:rise, @regular_percentage})
  end

  test "it does not trade when its an unsafe percentage" do
    assert :no_trades =
      BitArb.TradeMaker.check_for_trade({:rise, @unsafe_percentage})
  end

  test "it does not trade when the percentage is falling" do
    assert :no_trades =
      BitArb.TradeMaker.check_for_trade({:fall, @safe_percentage})
  end
end
