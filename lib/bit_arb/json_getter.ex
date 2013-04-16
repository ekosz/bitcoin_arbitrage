defmodule BitArb.JSONGetter do
  require Lager

  def get(url, http // :httpc) do
    do_get(url, http)
  end

  defp do_get(url, http) when is_binary(url) do
    do_get( binary_to_list(url), http )
  end

  defp do_get(url, http) do
    handle_response http.request(:get, {url, []},
                                 [{:timeout, 3000}, {:connect_timeout, 3000}],
                                 [{:body_format, :binary}])
  end

  def post(url, data, headers, http // :httpc) do
    handle_response http.request(:post, {url, headers, 'application/x-www-form-urlencoded; charset=UTF-8', data},
                                 [{:timeout, 3000}, {:connect_timeout, 3000}, {:ssl,[{:verify,0}]}],
                                 [{:body_format, :binary}])
  end

  defp handle_response({:ok, {{_, 200, _}, _headers, ""}}) do
    throw :empty_body
  end

  defp handle_response({:ok, {{_, 200, _}, _headers, body}}) do
    :jsx.decode(body)
  end

  defp handle_response({:ok, {{_, 500, _}, _headers, body}}) do
    data = :jsx.decode(body)
    Lager.error data["error"]
    throw binary_to_atom(data["token"])
  end

  defp handle_response({:error, _}) do
    throw :timeout
  end
end
