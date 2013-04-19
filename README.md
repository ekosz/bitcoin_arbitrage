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

1) The current Bitcoin to USD is $100
2) The current Bitcoin to EUR is €60
3) The current USD to EUR is €0.70

Now in a perfect economy all of these currencies would have the same value to
one another, but if you look closely the current Bitcoin to EUR is under priced
by €10!  This is an arbitrage opportunity.  We can safely say that the
market is going to want to balance itself. If the other exchange rates stay
content then the Bitcoin to EUR will eventually rise to €70.


What this program does is try and find these imbalances and capitalize on them.
