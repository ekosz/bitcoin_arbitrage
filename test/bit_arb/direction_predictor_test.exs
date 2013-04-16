Code.require_file "../../test_helper.exs", __FILE__

defmodule BitArb.DirectionPredictorTest do
  use ExUnit.Case

  test "it returns {:rise, 16.666} when the baseline is 100, ratio is 0.7, and to test is 60" do
    assert BitArb.DirectionPredictor.equate(100, 0.7, 60) == {:rise, (10/60)}
  end

  test "it returns {:fall, 12.5} when the baseline is 100, ratio is 0.7, and to test is 80" do
    assert BitArb.DirectionPredictor.equate(100, 0.7, 80) == {:fall, 0.125}
  end

  test "it returns {:equal, 0} when the baseline is 100, ratio is 0.7, and to test is 70" do
    assert BitArb.DirectionPredictor.equate(100, 0.7, 70) == {:equal, 0}
  end

end
