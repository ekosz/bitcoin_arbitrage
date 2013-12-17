defmodule BitArb.MtgoxGetter do
  @moduledoc """
  This module is in charge of creating requests that can be sent
  out to the MtGox bitcoin market.
  """

  require Lager

  @base_url 'http://data.mtgox.com/api/2/'
  @ticker '/money/ticker'

  @doc """
  Creates a request that is signed with special headers
  that help authenticate with the MtGox service.  This
  function requires that the `:mtgox_key` and the `:mtgox_secret`
  are set in the application environment variables.

  ## Example:

      ticker = signed_request('BTCUSD/money/ticker', 'nonce=123')

  """
  def signed_request(path, body, getter // BitArb.JSONGetter) do
    url       = @base_url ++ path
    hash_data = path ++ [0] ++ body
    secret    = :base64.decode_to_string(mtgox_secret)
    hmac      = :base64.encode_to_string(:hmac.hmac512(secret, hash_data))
    headers   = mtox_headers(hmac)

    Lager.debug "Posting to: #{url}, With body: #{body}, With headers: #{inspect headers}"
    getter.post(url, body, headers)["data"]
  end

  @doc """
  A helper method for making signed requests to
  '/BTC<symbol>/money/ticker'. It can take a currency in
  the form of a atom or a binary string.

  ## Example:

      sell_price = btc_to("USD")[:sell]

  """
  def btc_to(symbol, json_getter // BitArb.JSONGetter) do
    do_btc_to symbol, json_getter
  end

  defp do_btc_to(symbol, getter) when is_binary(symbol) do
    do_btc_to String.to_char_list!(symbol), getter
  end

  defp do_btc_to(symbol, getter) when is_atom(symbol) do
    do_btc_to atom_to_list(symbol), getter
  end

  defp do_btc_to(symbol, getter) do
    data = signed_request('BTC' ++ symbol ++ @ticker, nonce, getter)

    Enum.reduce data, [], fn({type, values}, acc) ->
      add_type_to_acc(acc, type, values)
    end
  end

  defp add_type_to_acc(acc, type, values) when is_list(values) do
    Keyword.put acc, binary_to_atom(type), find_value(values)
  end

  defp add_type_to_acc(acc, "now", time) do
    Keyword.put acc, :last_updated, binary_to_integer(time)
  end

  defp add_type_to_acc(acc, _, _) do
    acc
  end

  defp find_value([{"value", value} | _]) do
    binary_to_float(value)
  end

  defp find_value([ _ | rest ]) do
    find_value(rest)
  end

  defp nonce do
    String.to_char_list! "nonce=#{BitArb.now_in_millseconds}"
  end

  defp mtox_headers(hmac) do
    [{'User-Agent', 'Bit-Arb'},
     {'Rest-Key', mtgox_key},
     {'Rest-Sign', hmac}]
  end

  defp mtgox_key do
    {:ok, key} = :application.get_env(:bit_arb, :mtgox_key)
    key
  end

  defp mtgox_secret do
    {:ok, secret} = :application.get_env(:bit_arb, :mtgox_secret)
    secret
  end

end
