Code.require_file "../../test_helper.exs", __FILE__

defmodule BitArb.JSONGetterTest do
  use ExUnit.Case

  alias BitArb.JSONGetter, as: Getter

  test "it parses the JSON results" do
    defmodule GoodRequest do
      def request(_method, {'google', []}, _http_opts, _opts) do
        {:ok, {{:x, 200, :x}, :headers, %b({"result":"success"})}}
      end
    end

    assert Getter.get("google", GoodRequest) == [{"result", "success"}]
  end

  test "it throws :timeout when there is a timeout" do
    defmodule TimeoutRequest do
      def request(_method, {'google', []}, _http_opts, _opts) do
        {:error, :timeout}
      end
    end

    assert catch_throw(Getter.get("google", TimeoutRequest)) == :timeout
  end

end
