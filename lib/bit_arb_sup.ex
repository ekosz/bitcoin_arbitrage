defmodule BitArbSup do
  use Supervisor.Behaviour

  ## API

  def start_link do
    :supervisor.start_link(__MODULE__, [])
  end

  ## Callbacks

  def init([]) do
    children = [ worker(BitArb.OTP.ExchangeRatePoller, []),
                 worker(BitArb.OTP.MtgoxPoller, []),
                 worker(BitArb.OTP.Bank, []),
                 supervisor(BitArb.OTP.TradeSup, []),
                 supervisor(BitArb.OTP.TradeMakerSup, []) ]

    supervise(children, strategy: :one_for_one)
  end
end
