defmodule BitArb.OTP.DirectionPredictor do
  import BitArb.DirectionPredictor, only: [equate: 3]

  @one_min_ago 1000 * 60

  def predict(options) do
    from = Keyword.get options, :from
    to   = Keyword.get options, :to

    base_ratio = BitArb.OTP.ExchangeRatePoller.rate(from)
    test_ratio = BitArb.OTP.ExchangeRatePoller.rate(to)
    ratio = test_ratio / base_ratio

    base_price = retrive_price from, :buy
    test_price = retrive_price to,   :sell

    equate(base_price, ratio, test_price)
  end

  defp retrive_price(symbol, type) do
    prices    = BitArb.OTP.MtgoxPoller.price(symbol)
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
