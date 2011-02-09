Google Currency 1.1.1
=====================

Bugfixes
--------
 - Built gem using Ruby 1.8.7 to bypass a known error with RubyGems 1.5.0 and
   Ruby 1.9.2

Google Currency 1.1.0
=====================

Features
--------
 - Deprecated #get_google_rate, use #get_rate (thanks RMU Alumni)

Bugfixes
---------
 - Fixed an issue when rates over 1000 did not parse correctly (thanks Brandon
   Anderson)

Google Currency 1.0.3
=====================

Features
--------
 - Update `money` requirement to `~> 3.5`

Google Currency 1.0.2
=====================

Features
--------
 - Replace `eval` with `JSON.parse`
 - Use BigDecimal instead of Float

Bugfixes
--------
 - Quell parenthetical warnings in specs

Google Currency 1.0.1
=====================

Features
--------
 - Update `money` requirement to `~> 3.1.5`

Google Currency 1.0.0
=====================

Features
--------
 - Updated `money` requirement to `~> 3.1.0`

Google Currency 0.1.1
=====================

Features
--------
 - Added #flush_rates
 - Added #flush_rate

Google Currency 0.1.0
=====================

Features
--------
 - Initial release
