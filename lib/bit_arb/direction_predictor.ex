defmodule BitArb.DirectionPredictor do
  def equate(base, ratio, to_test) do
    price_it_should_be = base * ratio
    differance = abs( price_it_should_be - to_test )
    percentage = differance / to_test

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
