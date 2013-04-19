Code.require_file "../../../test_helper.exs", __FILE__

defmodule BitArb.OTP.BankTest do
  use ExUnit.Case

  defmodule FakeExchangeRatePoller do
    def rate(_symbol) do
      1
    end

    def rates do
      Enum.map BitArb.traded_symbols, fn(symbol) ->
        {symbol, length(BitArb.traded_symbols)}
      end
    end
  end

  defmodule FakeMtgoxPoller do
    def price(_symbol) do
      [sell: 1, buy: 1, value: 1]
    end
  end

  setup do
    BitArb.OTP.Bank.start_link(:test_bank, FakeExchangeRatePoller)
    :ok
  end

  teardown do
    BitArb.OTP.Bank.stop(:test_bank)
  end

  test "it initializes its holdings with $1000 USD in each" do
    Enum.each BitArb.OTP.Bank.holdings(:test_bank), fn({_name, value}) ->
      assert value == 1000
    end
  end

  test "it can retrive the amount for a certain holding" do
    assert BitArb.OTP.Bank.amount("EUR", :test_bank) == 1000
  end

  test "it can buy BTC" do
    BitArb.OTP.Bank.buy_btc_from("EUR", [amount: 100], :test_bank, FakeMtgoxPoller)

    assert BitArb.OTP.Bank.amount("EUR", :test_bank) == 900 - (100 * 0.006)
  end

  test "it can sell BTC" do
    BitArb.OTP.Bank.sell_btc_to("EUR", [amount: 100], :test_bank, FakeMtgoxPoller)

    assert BitArb.OTP.Bank.amount("EUR", :test_bank) == 1100 - (100 * 0.006)
  end

  test "it can give the net worth of all of the holdings" do
    assert_in_delta BitArb.OTP.Bank.net_worth(:test_bank, FakeExchangeRatePoller), 1000, 0.0001
  end

end
