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

Caveats
-------

This gem uses [Google Finance Converter](https://www.google.com/finance/converter) under the hood.

Exchange rates are,

1. Based on 1 unit of the original currency.
1. Have a precision of 4 decimal places.

What this means is that if the JPY to USD exchange rate is 0.0083660,
Google will report the JPY to USD exchange rate as 0.0084.
As a result, a larger JPY to USD conversion such as 10000 JPY to USD would yield 84 USD instead of 83.66 USD.

Consequently, this means that small exchange rates will be imprecise.
For example, if the IDR to USD exchange rate were 0.00007761, Google will report it as 0.0001.
This means 100000 IDR would exchange to 10 USD instead of 7.76 USD.

Copyright
---------

Copyright (c) 2011 Shane Emmons. See [LICENSE](LICENSE) for details.
