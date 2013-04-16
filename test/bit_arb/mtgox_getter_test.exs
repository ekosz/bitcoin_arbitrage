Code.require_file "../../test_helper.exs", __FILE__

defmodule BitArb.MtgoxGetterTest do
  use ExUnit.Case

  alias BitArb.MtgoxGetter, as: Getter

  defmodule JSONGetterMock do
    def post(_url, _data, _headers) do
      [{"result", "success"}, {"data", [{"high",       [{"value", "266.00000"}]},
                                        {"low",        [{"value", "105.00000"}]},
                                        {"avg",        [{"value", "215.77692"}]},
                                        {"vwap",       [{"value", "198.14325"}]},
                                        {"last_local", [{"value", "191.00000"}]},
                                        {"last_orig",  [{"value", "191.00000"}]},
                                        {"last_all",   [{"value", "191.00000"}]},
                                        {"last",       [{"value", "191.00000"}]},
                                        {"buy",        [{"value", "191.00000"}]},
                                        {"sell",       [{"value", "198.40000"}]},
                                        {"currency", "USD"}]}]
    end
  end

  test "it only returns the importent symbols" do
    results = Getter.btc_to('USD', JSONGetterMock)

    assert results[:high] == 266.0
    assert results[:low]  == 105.0
    assert results[:avg]  == 215.77692
    assert results[:vwap] == 198.14325
    assert results[:last] == 191.0
    assert results[:buy]  == 191.0
    assert results[:sell] == 198.4
  end
end
