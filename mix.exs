defmodule BitArb.Mixfile do
  use Mix.Project

  def project do
    [ app: :bit_arb,
      version: "0.0.1",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    [ applications: [:exlager],
      registered: [:bit_arb],
      env: [ {:open_exchange_api_key, 'OPEN_EXCHANGE_API_KEY'},
             {:mtgox_key, 'MTGOX_KEY'},
             {:mtgox_secret, 'MTGOX_SECRET'} ],
      mod: { BitArb, [] } ]
  end

  defp deps do
    [ { :erlsha2, %r(.*), github: "vinoski/erlsha2" },
      { :exlager, %r(.*), github: "khia/exlager" },
      { :jsx,"1.3.3",[github: "talentdeficit/jsx", tag: "v1.3.3"]} ]
  end
end
