module Money::RatesStore
  module RateRemovalSupport
    # Remove a conversion rate and returns it. Uses +Mutex+ to synchronize data access.
    #
    # @param [String] currency_iso_from Currency to exchange from.
    # @param [String] currency_iso_to Currency to exchange to.
    #
    # @return [Numeric]
    #
    # @example
    #   store = Money::RatesStore::Memory.new
    #   store.remove_rate("USD", "CAD")
    #   store.remove_rate("CAD", "USD")
    def remove_rate(currency_iso_from, currency_iso_to)
      transaction { index.delete rate_key_for(currency_iso_from, currency_iso_to) }
    end

    # Clears all conversion rates. Uses +Mutex+ to synchronize data access.
    #
    # @example
    #   store = Money::RatesStore::Memory.new
    #   store.clear_rates
    def clear_rates
      transaction { @index = {} }
    end
  end
end
