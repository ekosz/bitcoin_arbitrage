defmodule BitArb.ExchangeRateGetter do
  @moduledoc """
  This module is in charge of the business logic for retrieving the
  latest worldwide currency exchange rates.
  """

  require Lager
  @base_url 'http://openexchangerates.org'
  @api_namespace '/api'
  @latest_endpoint '/latest.json'

  @doc """
  Retrieves the current rates from OpenEcchangeRates.org. It requires
  that the :open_exchange_api_key is set in the application environment.
  """
  def get_current(json_getter // nil) do
    if !json_getter && Mix.env == :test do
      [{"USD", 1}, {"EUR", 0.7}, {"GBP", 2}, {"AUD", 1.1}, {"JPY", 100}, {"PLN", 0.5}, {"CAD", 0.9}]
    else
      json_getter = json_getter || BitArb.JSONGetter
      important_symbols json_getter.get(latest_url)["rates"]
    end
  end

  defp latest_url do
    @base_url ++ @api_namespace ++ @latest_endpoint ++ '?' ++ api_key
  end

  defp important_symbols(rates) do
    Enum.filter rates, fn({symbol, _val}) ->
      List.member? BitArb.traded_symbols, symbol
    end
  end

  defp api_key do
    {:ok, key} = :application.get_env(:bit_arb, :open_exchange_api_key)
    'app_id=' ++ key
  end
end
