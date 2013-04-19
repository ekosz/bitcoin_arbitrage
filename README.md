# Bitcoin Arbitrage

This is a proof of concept for finding arbitrage opportunities in bitcoin
markets and making trades on those opportunities.

> "In economics and finance, arbitrage (pron.: /ˈɑrbɨtrɑːʒ/) is the practice of
> taking advantage of a price difference between two or more markets: striking
> a combination of matching deals that capitalize upon the imbalance, the
> profit being the difference between the market prices."

Example
------

Lets say we have three numbers

1. The current Bitcoin to USD is $100
2. The current Bitcoin to EUR is €60
3. The current USD to EUR is €0.70

Now in a perfect economy all of these currencies would have the same value to
one another, but if you look closely the current Bitcoin to EUR is under priced
by €10!  This is an arbitrage opportunity.  We can safely say that the market
is going to want to balance itself. If the other exchange rates stay content
then the Bitcoin to EUR will eventually rise to €70.

What this program does is try and find these imbalances and capitalize on them.

Buy Signal
---------

If we find a under priced conversion and we predict it will rise more than 3.6%
(3 times the assumed trading fee for going in and out).  If we predict it will
rise more than four times our trading fee (4.8%) then we invest more money into
the trade as its safer.

Sell Signal
-----------

If the conversion rises to one third of our initial prediction, or falls in
price 10% (a stop loss). This algorithm trades very safely.  These numbers can
be tweaked to have a higher risk / higher reward.

Third Part Dependencies
-----------------------

Currently this program is limited to the [MtGox bitcoin
exchange](https://mtgox.com/) and grabs its global exchanges rates from [Open
Exchange Rates](https://openexchangerates.org/). API keys and secrets must be
set in the `mix.exs` for the program to run properly.

Installation
-----------

1. Make sure Erlang and Elixir are installed
2. Clone this repo: `git clone https://github.com/ekosz/bitcoin_arbitrage.git`
3. Move into the directory: `cd bitcoin_arbitrge`
4. Install the dependencies: `mix deps.get`
5. Set your credentials in `mix.exs`
6. Run the program: `iex -S mix`
