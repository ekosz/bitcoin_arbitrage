defmodule BitArb.Bank do
  @fee 0.006

  def find_holding(holdings, symbol) when is_binary(symbol) do
    find_holding(holdings, binary_to_atom(symbol))
  end

  def find_holding(holdings, symbol) when is_atom(symbol) do
    holdings[symbol]
  end

  def retrive_amount_from_holding(holdings, symbol, buy_price, amount) when is_binary(symbol) do
    retrive_amount_from_holding holdings, binary_to_atom(symbol), buy_price, amount
  end

  def retrive_amount_from_holding(holdings, symbol, buy_price, amount) when is_atom(symbol) do
    if holdings[symbol] > amount do
      amount_bought = amount / buy_price
      reply = {:ok, buy_price, amount_bought}

      {reply, Keyword.put(holdings, symbol, holdings[symbol] - amount - (amount * @fee))}
    else
      {:insufficient_funds, holdings}
    end
  end

  def put_amount_into_holding(holdings, symbol, sell_price, btc_amount) when is_binary(symbol) do
    put_amount_into_holding holdings, binary_to_atom(symbol), sell_price, btc_amount
  end

  def put_amount_into_holding(holdings, symbol, sell_price, btc_amount) do
    amount = sell_price * btc_amount
    reply = {:ok, sell_price, amount}

    {reply, Keyword.put(holdings, symbol, holdings[symbol] + amount - (amount * @fee))}
  end

  def value_of_holdings(holdings, conversions) do
    Enum.reduce holdings, 0, fn({name, amount}, acc) ->
      acc + (amount / conversions[atom_to_binary(name)])
    end
  end
end
