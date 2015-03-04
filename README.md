Google Currency
===============

[![Build Status](https://secure.travis-ci.org/RubyMoney/google_currency.png)](http://travis-ci.org/RubyMoney/google_currency)

This gem extends Money::Bank::VariableExchange with Money::Bank::GoogleCurrency
and gives you access to the current Google Currency exchange rates.

Usage
-----

    require 'money'
    require 'money/bank/google_currency'

    # (optional)
    # set the seconds after than the current rates are automatically expired
    # by default, they never expire
    Money::Bank::GoogleCurrency.ttl_in_seconds = 86400

    # set default bank to instance of GoogleCurrency
    Money.default_bank = Money::Bank::GoogleCurrency.new

    # create a new money object, and use the standard #exchange_to method
    money = Money.new(1_00, "USD") # amount is in cents
    money.exchange_to(:EUR)

    # or install and use the 'monetize' gem
    require 'monetize'
    money = 1.to_money(:USD)
    money.exchange_to(:EUR)

An `UnknownRate` will be thrown if `#exchange_to` is called with a `Currency`
that `Money` knows, but Google does not.

An `UnknownCurrency` will be thrown if `#exchange_to` is called with a
`Currency` that `Money` does not know.

A `GoogleCurrencyFetchError` will be thrown if there is an unknown issue with the Google Finance Converter API.

Copyright
---------

Copyright (c) 2011 Shane Emmons. See [LICENSE](LICENSE) for details.
