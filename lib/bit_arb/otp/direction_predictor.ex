defmodule BitArb.OTP.DirectionPredictor do
  import BitArb.DirectionPredictor, only: [equate: 3]

  @one_min_ago 1000 * 60

  def predict(options, exchange_rate_poller // BitArb.OTP.ExchangeRatePoller,
                       bitcoin_poller // BitArb.OTP.MtgoxPoller) do
    from = Keyword.get options, :from
    to   = Keyword.get options, :to

    base_ratio = exchange_rate_poller.rate(from)
    test_ratio = exchange_rate_poller.rate(to)
    ratio = test_ratio / base_ratio

    base_price = retrieve_price from, :buy,  bitcoin_poller
    test_price = retrieve_price to,   :sell, bitcoin_poller

    equate(base_price, ratio, test_price)
  end

  defp retrieve_price(symbol, type, bitcoin_poller) do
    prices    = bitcoin_poller.price(symbol)
    now       = BitArb.now_in_millseconds
    then      = prices[:last_updated] / 1000
    diffrance = now - then
    if diffrance > @one_min_ago do
      throw {:data_too_old, now, then, diffrance}
    else
      prices[type]
    end
  end
end
