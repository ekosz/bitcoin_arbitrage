Code.require_file "../../test_helper.exs", __FILE__

defmodule BitArb.BankTest do
  use ExUnit.Case

  @holdings            [a: 10]
  @unit_price          2
  @amount_to_purchase  6
  @amount_to_sell  10

  test "it is able to find a holding, when the key is a binary " do
    holdings = [a: 1]

    assert BitArb.Bank.find_holding(holdings, "a") == 1
  end

  test "it buys (amount_to_purchase / unit_price) units" do
    {{:ok, _buy_price, amount_bought}, _updated_holdings} =
      BitArb.Bank.retrive_amount_from_holding(@holdings, :a, @unit_price, @amount_to_purchase)

    assert amount_bought == 3
  end

  test "it subtracts the amount_to_purchase from the holding" do
    {{:ok, _buy_price, _amount_bought}, updated_holdings} =
      BitArb.Bank.retrive_amount_from_holding(@holdings, :a, @unit_price, @amount_to_purchase)

    assert updated_holdings[:a] == 3.964
  end

  test "it respondes with :insufficient_funds when there isn't enough money in the holding" do
    holdings = [a: 0]

    assert {:insufficient_funds, _updated_holdings} =
      BitArb.Bank.retrive_amount_from_holding(holdings, :a, @unit_price, @amount_to_purchase)
  end

  test "it doesn't change the holdings when there isn't enough money in the holding" do
    holdings = [a: 0]

    {:insufficient_funds, updated_holdings} =
      BitArb.Bank.retrive_amount_from_holding(holdings, :a, @unit_price, @amount_to_purchase)

    assert updated_holdings == holdings
  end

  test "it sells (amount_to_sell * unit_price) moneys" do
    {{:ok, _sell_price, total_sold}, _updated_holdings} =
      BitArb.Bank.put_amount_into_holding(@holdings, :a, @unit_price, @amount_to_sell)

    assert total_sold == 20
  end

  test "it adds the total_sold to the holding" do
    {{:ok, _sell_price, _total_sold}, updated_holdings} =
      BitArb.Bank.put_amount_into_holding(@holdings, :a, @unit_price, @amount_to_sell)

    assert updated_holdings[:a] == 29.88
  end

  test "it calculates the total net worth of the holdings" do
    holdings = [a: 10, b: 21]
    convertions = [{"a", 5}, {"b", 3}]

    assert BitArb.Bank.value_of_holdings(holdings, convertions) == 9
  end
end
