Google Currency
===============

This gem extends Money::Bank::VariableExchange with Money::Bank::GoogleCurrency
and gives you access to the current Google Currency exchange rates.

Usage
-----

    require 'money'
    require 'money/bank/google_currency'

    # set default bank to instance of GoogleCurrency
    Money.default_bank = Money::Bank::GoogleCurrency.new

    # create a new money object, and use the standard #exchange_to method
    n = 1.to_money(:USD)
    n.exchange_to(:EUR)

An `UnknownRate` will be thrown if `#exchange_to` is called with a `Currency`
that `Money` knows, but Google does not.

An `UnknownCurrency` will be thrown if `#exchange_to` is called with a
`Currency` that `Money` does not know.

Copyright
---------

Copyright (c) 2010 Shane Emmons. See {file:LICENSE} for details.
