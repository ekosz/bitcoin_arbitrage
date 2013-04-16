defmodule BitArb.DirectionPredictor do
  @doc """
  Gives a prediction that a currency is going to rise or fall
  depending on a base currency and the normal ratio that the
  two currencies should have.  If the currency to test is
  below where it expects it returns that it should rise. If
  its above, it returns that it should fall.

  ## Example:

      {:fall, amount} = BitArb.DirectionPredictor.equate(100, 0.7, 80)

  """
  def equate(base, ratio, to_test) do
    price_it_should_be = base * ratio
    difference = abs( price_it_should_be - to_test )
    percentage = difference / to_test

    cond do
      price_it_should_be == to_test ->
        {:equal, 0}
      price_it_should_be > to_test ->
        {:rise, percentage}
      true ->
        {:fall, percentage}
    end
  end
end
