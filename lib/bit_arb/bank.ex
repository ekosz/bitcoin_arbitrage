defmodule BitArb.Bank do
  @moduledoc """
  This module provides the business logic to the Bank GenServer.
  It provides logic for converting bitcoins in and out of
  currencies.
  """

  @fee 0.006

  @doc """
  Returns the value of the currency in a holding. It can take an
  atom or a binary key.
  """
  def find_holding(holdings, symbol) when is_binary(symbol) do
    find_holding(holdings, binary_to_atom(symbol))
  end

  def find_holding(holdings, symbol) when is_atom(symbol) do
    holdings[symbol]
  end

  @doc """
  Updates a holding. Takes a certain amount money out of it
  depending on the buy_price and the amount. It also subtracts
  the trading fee from the holding.  If there isn't enough
  money in the holding it will return insufficient_funds.
  It can take an atom or a binary as a currency key.

  ## Example:

      {{:ok, buy_price, amount_bought}, updated_holdings} =
        retrieve_amount_from_holding(holdings, currency, buy_price, amount_to_purchase)

  """
  def retrieve_amount_from_holding(holdings, symbol, buy_price, amount) when is_binary(symbol) do
    retrieve_amount_from_holding holdings, binary_to_atom(symbol), buy_price, amount
  end

  def retrieve_amount_from_holding(holdings, symbol, buy_price, amount) when is_atom(symbol) do
    if holdings[symbol] > amount do
      amount_bought = amount / buy_price
      reply = {:ok, buy_price, amount_bought}

      {reply, Keyword.put(holdings, symbol, holdings[symbol] - amount - (amount * @fee))}
    else
      {:insufficient_funds, holdings}
    end
  end

  @doc """
  Updates a holding. It puts a certain amount money into it
  depending on the sell_price and the amount. It also subtracts
  the trading fee from the holding.  It can take an atom or a
  binary as a currency key.

  ## Example:

      {{:ok, sell_price, total_sold}, updated_holdings} =
        put_amount_into_holding(holdings, currency, sell_price, amount_to_sell)

  """
  def put_amount_into_holding(holdings, symbol, sell_price, btc_amount) when is_binary(symbol) do
    put_amount_into_holding holdings, binary_to_atom(symbol), sell_price, btc_amount
  end

  def put_amount_into_holding(holdings, symbol, sell_price, btc_amount) do
    amount = sell_price * btc_amount
    reply = {:ok, sell_price, amount}

    {reply, Keyword.put(holdings, symbol, holdings[symbol] + amount - (amount * @fee))}
  end

  @doc """
  Returns the total value of a holding based off of a
  conversion map.

  ## Example:

      holdings = [a: 10, b: 21]
      conversions = [{"a", 5}, {"b", 3}]

      9 = value_of_holdings(holdings, conversions)

  """
  def value_of_holdings(holdings, conversions) do
    Enum.reduce holdings, 0, fn({name, amount}, acc) ->
      acc + (amount / conversions[atom_to_binary(name)])
    end
  end
end
