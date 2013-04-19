Code.require_file "../../../test_helper.exs", __FILE__

defmodule BitArb.OTP.DirectionPredictorTest do
  use ExUnit.Case

  defmodule FakeExchangeRatePoller do
    def rate(_symbol) do
      1
    end
  end

  defmodule USDDoubleEUR do
    def price(symbol) do
      prices = [USD: [buy: 2, sell: 2, last_updated: BitArb.now_in_millseconds * 1000],
                EUR: [buy: 1, sell: 1, last_updated: BitArb.now_in_millseconds * 1000]]
      prices[binary_to_atom(symbol)]
    end
  end

  test "it returns it is going to rise when the test is lower than the base" do
    assert {:rise, 1.0} =
      BitArb.OTP.DirectionPredictor.predict([from: "USD", to: "EUR"],
                                            FakeExchangeRatePoller, USDDoubleEUR)
  end

  test "it returns it is going to fall when the test is higher than the base" do
    assert {:fall, 0.5} =
      BitArb.OTP.DirectionPredictor.predict([from: "EUR", to: "USD"],
                                            FakeExchangeRatePoller, USDDoubleEUR)
  end

  defmodule USDVeryOld do
    def price(symbol) do
      prices = [USD: [buy: 2, sell: 2, last_updated: 0],
                EUR: [buy: 1, sell: 1, last_updated: BitArb.now_in_millseconds * 1000]]
      prices[binary_to_atom(symbol)]
    end
  end

  test "it throws :data_too_old when the last updated are more than a minute apart" do
    caught = catch_throw(
      BitArb.OTP.DirectionPredictor.predict([from: "EUR", to: "USD"],
                                            FakeExchangeRatePoller, USDVeryOld)
    )

    assert elem(caught, 0) == :data_too_old
  end
end
