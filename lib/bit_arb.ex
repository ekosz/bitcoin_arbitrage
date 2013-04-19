defmodule BitArb do
  use Application.Behaviour

  @doc """
  The application callback used to start this
  application and its Dynamos.
  """
  def start(_type, _args) do
    BitArbSup.start_link
  end

  def traded_symbols do
    ["USD", "EUR", "GBP", "AUD", "JPY", "PLN", "CAD"]
  end

  def now_in_millseconds do
    {mega, secs, _} = :erlang.now()
    (mega * 1_000_000 + secs) * 1_000
  end
end
