Code.require_file "../../test_helper.exs", __FILE__

defmodule BitArb.ExchangeRateGetterTest do
  use ExUnit.Case

  alias BitArb.ExchangeRateGetter, as: Getter

  defmodule JSONGetterMock do
    def get(_url) do
      [{"rates", [{"EUR", 5}, {"BAD", 10}]}]
    end
  end

  test "it only returns the importent symbols" do
    results = Getter.get_current(JSONGetterMock)

    assert results["EUR"] == 5
    assert results["BAD"] == nil
  end
end
