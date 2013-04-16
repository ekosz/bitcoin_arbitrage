defmodule BitArb.OTP.TradeSup do
  use Supervisor.Behaviour

  def start_link do
    :supervisor.start_link({:local, __MODULE__}, __MODULE__, [])
  end

  def create_trade(from, amount, to, sell_price) do
    :supervisor.start_child(__MODULE__, [from, amount, to, sell_price])
  end

  def init([]) do
    supervise([worker(BitArb.OTP.Trade, [])], strategy: :simple_one_for_one)
  end
end
