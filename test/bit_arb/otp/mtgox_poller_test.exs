Code.require_file "../../../test_helper.exs", __FILE__

defmodule BitArb.OTP.MtgoxPollerTest do
  use ExUnit.Case

  @prices Enum.reduce BitArb.traded_symbols, [], fn(name, acc) ->
            Keyword.put acc, binary_to_atom(name), 1
          end

  defmodule FakeTimer do
    def send_after(_time, _msg) do
      {:ok, self}
    end

    def sleep(_amount) do
    end
  end

  defmodule FakeGetter do
    def btc_to(_symbol) do
      1
    end
  end

  setup do
    BitArb.OTP.MtgoxPoller.start_link(:mtgox_poller_test, FakeTimer, FakeGetter)
    :ok
  end

  teardown do
    BitArb.OTP.MtgoxPoller.stop(:mtgox_poller_test)
  end

  test "it returns all of its prices" do
    assert BitArb.OTP.MtgoxPoller.prices(:mtgox_poller_test) == @prices
  end

  test "it returns a spesific price" do
    assert BitArb.OTP.MtgoxPoller.price("USD", :mtgox_poller_test) == @prices[:USD]
  end

  test "it throws :price_not_ready when the price isn't set yet" do
    caught = catch_throw(BitArb.OTP.MtgoxPoller.price("BAD", :mtgox_poller_test))

    assert caught == :price_not_ready
  end
end
