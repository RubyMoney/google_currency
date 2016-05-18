Google Currency
===============

[![Build Status](https://secure.travis-ci.org/RubyMoney/google_currency.png)](http://travis-ci.org/RubyMoney/google_currency)

This gem extends Money::Bank::VariableExchange with Money::Bank::GoogleCurrency
and gives you access to the current Google Currency exchange rates.

**WARNING! [Google Finance Converter](https://www.google.com/finance/converter)
(used by this gem) has been deprecated by Google. It is still available, but no
longer supported. Use at your own risk!**

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

Known issues
------------

Unsupported currencies: `BYN`, `CUC`, `EEK`, `GGP`, `GHC`, `IMP`, `JEP`, `MTL`,
`SSP`, `TMM`, `XAG`, `XAU`, `YEN`, `ZWD`, `ZWN`, `ZWR`.

Unsupported exchanges:
- `AED -> ZMK`
- `AFN -> SKK, ZMK, BTC`
- `ALL -> SKK, ZMK, BTC`
- `AMD -> SKK, ZMK, BTC`
- `ANG -> ZMK`
- `AOA -> SKK, ZMK, BTC`
- `ARS -> ZMK`
- `AUD -> ZMK`
- `AWG -> SKK, ZMK`
- `AZN -> SKK, ZMK`
- `BAM -> SKK, ZMK`
- `BBD -> SKK, ZMK`
- `BDT -> ZMK, BTC`
- `BGN -> ZMK`
- `BHD -> ZMK`
- `BIF -> CLF, SKK, ZMK, BTC`
- `BMD -> SKK, ZMK`
- `BND -> ZMK`
- `BOB -> ZMK`
- `BRL -> ZMK`
- `BSD -> SKK, ZMK`
- `BTC -> SKK, ZMK`
- `BTN -> SKK, ZMK, BTC`
- `BWP -> ZMK`
- `BYR -> BHD, CLF, EUR, FKP, GBP, GIP, JOD, KWD, KYD, LVL, OMR, SHP, SKK, XDR, ZMK, BTC`
- `BZD -> SKK, ZMK`
- `CAD -> ZMK`
- `CDF -> CLF, SKK, ZMK, BTC`
- `CHF -> ZMK`
- `CLF -> SKK, ZMK`
- `CLP -> CLF, ZMK, BTC`
- `CNY -> ZMK`
- `COP -> CLF, ZMK, BTC`
- `CRC -> CLF, ZMK, BTC`
- `CUP -> SKK, ZMK`
- `CVE -> SKK, ZMK, BTC`
- `CZK -> ZMK`
- `DJF -> SKK, ZMK, BTC`
- `DKK -> ZMK`
- `DOP -> ZMK, BTC`
- `DZD -> ZMK, BTC`
- `EGP -> ZMK`
- `ERN -> SKK, ZMK`
- `ETB -> SKK, ZMK`
- `EUR -> ZMK`
- `FJD -> ZMK`
- `FKP -> SKK, ZMK`
- `GBP -> ZMK`
- `GEL -> SKK, ZMK`
- `GHS -> SKK, ZMK`
- `GIP -> SKK, ZMK`
- `GMD -> SKK, ZMK`
- `GNF -> CLF, KWD, SKK, ZMK, BTC`
- `GTQ -> SKK, ZMK`
- `GYD -> SKK, ZMK, BTC`
- `HKD -> ZMK`
- `HNL -> ZMK`
- `HRK -> ZMK`
- `HTG -> SKK, ZMK, BTC`
- `HUF -> ZMK, BTC`
- `IDR -> BHD, CLF, FKP, KWD, LVL, OMR, ZMK, BTC`
- `ILS -> ZMK`
- `INR -> ZMK, BTC`
- `IQD -> CLF, SKK, ZMK, BTC`
- `IRR -> AUD, AZN, BHD, BMD, BND, BSD, CAD, CHF, CLF, CUP, EUR, FKP, GBP, GIP, JOD, KWD, KYD, LVL, LYD, NZD, OMR, PAB, SGD, SHP, SKK, USD, XDR, ZMK, BTC`
- `ISK -> SKK, ZMK, BTC`
- `JMD -> ZMK, BTC`
- `JOD -> ZMK`
- `JPY -> ZMK, BTC`
- `KES -> ZMK, BTC`
- `KGS -> SKK, ZMK, BTC`
- `KHR -> CLF, SKK, ZMK, BTC`
- `KMF -> SKK, ZMK, BTC`
- `KPW -> CLF, SKK, ZMK, BTC`
- `KRW -> CLF, ZMK, BTC`
- `KWD -> ZMK`
- `KYD -> ZMK`
- `KZT -> ZMK, BTC`
- `LAK -> BHD, CLF, KWD, OMR, SKK, ZMK, BTC`
- `LBP -> CLF, ZMK, BTC`
- `LKR -> ZMK, BTC`
- `LRD -> SKK, ZMK, BTC`
- `LSL -> SKK, ZMK`
- `LTL -> ZMK`
- `LVL -> ZMK`
- `LYD -> SKK, ZMK`
- `MAD -> ZMK`
- `MDL -> ZMK`
- `MGA -> CLF, SKK, ZMK, BTC`
- `MKD -> ZMK, BTC`
- `MMK -> CLF, SKK, ZMK, BTC`
- `MNT -> CLF, SKK, ZMK, BTC`
- `MOP -> SKK, ZMK`
- `MRO -> SKK, ZMK, BTC`
- `MUR -> ZMK`
- `MVR -> ZMK`
- `MWK -> CLF, SKK, ZMK, BTC`
- `MXN -> ZMK`
- `MYR -> ZMK`
- `MZN -> SKK, ZMK, BTC`
- `NAD -> ZMK`
- `NGN -> ZMK, BTC`
- `NIO -> ZMK`
- `NOK -> ZMK`
- `NPR -> ZMK, BTC`
- `NZD -> ZMK`
- `OMR -> ZMK`
- `PAB -> SKK, ZMK`
- `PEN -> ZMK`
- `PGK -> ZMK`
- `PHP -> ZMK, BTC`
- `PKR -> ZMK, BTC`
- `PLN -> ZMK`
- `PYG -> CLF, ZMK, BTC`
- `QAR -> ZMK`
- `RON -> ZMK`
- `RSD -> ZMK, BTC`
- `RUB -> ZMK, BTC`
- `RWF -> CLF, SKK, ZMK, BTC`
- `SAR -> ZMK`
- `SBD -> SKK, ZMK`
- `SCR -> ZMK`
- `SDG -> SKK, ZMK`
- `SEK -> ZMK`
- `SGD -> ZMK`
- `SHP -> SKK, ZMK`
- `SKK -> AFN, ALL, AMD, AOA, AWG, AZN, BAM, BBD, BIF, BMD, BSD, BTN, BYR, BZD, CDF, CLF, CUP, CVE, DJF, ERN, ETB, FKP, GEL, GHS, GIP, GMD, GNF, GTQ, GYD, HTG, IQD, IRR, ISK, KGS, KHR, KMF, KPW, LAK, LRD, LSL, LYD, MGA, MMK, MNT, MOP, MRO, MWK, MZN, PAB, RWF, SBD, SDG, SHP, SOS, SRD, STD, SYP, SZL, TJS, TMT, TOP, VUV, WST, XCD, XDR, XPF, BTC, ZWL`
- `SLL -> CLF, ZMK, BTC`
- `SOS -> CLF, SKK, ZMK, BTC`
- `SRD -> SKK, ZMK`
- `STD -> BHD, BMD, BSD, CHF, CLF, CUP, EUR, FKP, GBP, GIP, JOD, KWD, KYD, LVL, OMR, PAB, SHP, SKK, USD, XDR, ZMK, BTC`
- `SVC -> ZMK`
- `SYP -> SKK, ZMK, BTC`
- `SZL -> SKK, ZMK`
- `THB -> ZMK`
- `TJS -> SKK, ZMK`
- `TMT -> SKK, ZMK`
- `TND -> ZMK`
- `TOP -> SKK, ZMK`
- `TRY -> ZMK`
- `TTD -> ZMK`
- `TWD -> ZMK`
- `TZS -> CLF, ZMK, BTC`
- `UAH -> ZMK`
- `UGX -> CLF, ZMK, BTC`
- `USD -> ZMK`
- `UYU -> ZMK`
- `UZS -> CLF, ZMK, BTC`
- `VEF -> ZMK`
- `VND -> BHD, BMD, BSD, CHF, CLF, CUP, EUR, FKP, GBP, GIP, JOD, KWD, KYD, LVL, OMR, PAB, SHP, USD, XDR, ZMK, BTC`
- `VUV -> SKK, ZMK, BTC`
- `WST -> SKK, ZMK`
- `XAF -> CLF, ZMK, BTC`
- `XCD -> SKK, ZMK`
- `XDR -> SKK, ZMK`
- `XOF -> CLF, ZMK, BTC`
- `XPF -> SKK, ZMK, BTC`
- `YER -> ZMK, BTC`
- `ZAR -> ZMK`
- `ZMK -> AED, AFN, ALL, AMD, ANG, AOA, ARS, AUD, AWG, AZN, BAM, BBD, BDT, BGN, BHD, BMD, BND, BOB, BRL, BSD, BTN, BWP, BZD, CAD, CHF, CLF, CLP, CNY, CRC, CUP, CVE, CZK, DJF, DKK, DOP, DZD, EGP, ERN, ETB, EUR, FJD, FKP, GBP, GEL, GHS, GIP, GMD, GTQ, GYD, HKD, HNL, HRK, HTG, HUF, ILS, INR, ISK, JMD, JOD, JPY, KES, KGS, KMF, KWD, KYD, KZT, LKR, LRD, LSL, LTL, LVL, LYD, MAD, MDL, MKD, MOP, MRO, MUR, MVR, MWK, MXN, MYR, MZN, NAD, NGN, NIO, NOK, NPR, NZD, OMR, PAB, PEN, PGK, PHP, PKR, PLN, QAR, RON, RSD, RUB, SAR, SBD, SCR, SDG, SEK, SGD, SHP, SRD, SVC, SYP, SZL, THB, TJS, TMT, TND, TOP, TRY, TTD, TWD, UAH, USD, UYU, VEF, VUV, WST, XAF, XCD, XDR, XOF, XPF, YER, ZAR, ZMW, BTC, ZWL`
- `ZMW -> ZMK`
- `ZWL -> SKK, ZMK, BTC`

Copyright
---------

Copyright (c) 2011 Shane Emmons. See [LICENSE](LICENSE) for details.
