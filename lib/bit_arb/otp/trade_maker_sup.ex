defmodule BitArb.OTP.TradeMakerSup do
  use Supervisor.Behaviour

  def start_link do
    :supervisor.start_link({:local, __MODULE__}, __MODULE__, [])
  end

  def init([]) do
    trade_makers = Enum.reduce BitArb.traded_symbols, [], fn(base, acc) ->
      Enum.reduce BitArb.traded_symbols, acc, fn(test, acc_two) ->
        if base != test do
          acc_two ++ [worker(BitArb.OTP.TradeMaker, [base, test], [id: "#{base}_to_#{test}"])]
        else
          acc_two
        end
      end
    end

    supervise(trade_makers, strategy: :one_for_one)
  end
end
