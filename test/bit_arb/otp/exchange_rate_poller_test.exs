Code.require_file "../../../test_helper.exs", __FILE__

defmodule BitArb.OTP.ExchangeRatePollerTest do
  use ExUnit.Case

  @rates [{"USD", 1}]

  defmodule FakeTimer do
    def send_after(_time, _msg) do
      {:ok, self}
    end
  end

  defmodule FakeGetter do
    def get_current do
      [{"USD", 1}]
    end
  end

  setup do
    BitArb.OTP.ExchangeRatePoller.start_link(:exchange_rate_poller_test,
                                             FakeTimer, FakeGetter)
    :ok
  end

  teardown do
    BitArb.OTP.ExchangeRatePoller.stop(:exchange_rate_poller_test)
  end

  test "it returns all of its rates" do
    assert BitArb.OTP.ExchangeRatePoller.rates(:exchange_rate_poller_test) == @rates
  end

  test "it returns a single rate" do
    assert BitArb.OTP.ExchangeRatePoller.rate("USD", :exchange_rate_poller_test) == 1
  end

end
