require 'money'
require 'money/rates_store/rate_removal_support'
require 'open-uri'

class Money
  module Bank
    # Raised when there is an unexpected error in extracting exchange rates
    # from Google Finance Calculator
    class GoogleCurrencyFetchError < Error
    end

    class GoogleCurrency < Money::Bank::VariableExchange


      SERVICE_HOST = "www.google.com"
      SERVICE_PATH = "/finance/converter"


      # @return [Hash] Stores the currently known rates.
      attr_reader :rates


      class << self
        # @return [Integer] Returns the Time To Live (TTL) in seconds.
        attr_reader :ttl_in_seconds

        # @return [Time] Returns the time when the rates expire.
        attr_reader :rates_expiration

        attr_reader :shared_rates_store
        attr_reader :shared_rates_store_expires_in

        ##
        # Set the Time To Live (TTL) in seconds.
        #
        # @param [Integer] the seconds between an expiration and another.
        def ttl_in_seconds=(value)
          @ttl_in_seconds = value
          refresh_rates_expiration! if ttl_in_seconds
        end

        def shared_rates_store=(store)
          @shared_rates_store = store
        end

        def shared_rates_store_expires_in=(expires_in)
          @shared_rates_store_expires_in = expires_in
        end

        ##
        # Set the rates expiration TTL seconds from the current time.
        #
        # @return [Time] The next expiration.
        def refresh_rates_expiration!
          @rates_expiration = Time.now + ttl_in_seconds
        end
      end

      def initialize(*)
        super
        @store.extend Money::RatesStore::RateRemovalSupport
      end

      ##
      # Clears all rates stored in @rates
      #
      # @return [Hash] The empty @rates Hash.
      #
      # @example
      #   @bank = GoogleCurrency.new  #=> <Money::Bank::GoogleCurrency...>
      #   @bank.get_rate(:USD, :EUR)  #=> 0.776337241
      #   @bank.flush_rates           #=> {}
      def flush_rates
        store.clear_rates
      end

      ##
      # Clears the specified rate stored in @rates.
      #
      # @param [String, Symbol, Currency] from Currency to convert from (used
      #   for key into @rates).
      # @param [String, Symbol, Currency] to Currency to convert to (used for
      #   key into @rates).
      #
      # @return [Float] The flushed rate.
      #
      # @example
      #   @bank = GoogleCurrency.new    #=> <Money::Bank::GoogleCurrency...>
      #   @bank.get_rate(:USD, :EUR)    #=> 0.776337241
      #   @bank.flush_rate(:USD, :EUR)  #=> 0.776337241
      def flush_rate(from, to)
        store.remove_rate(from, to)
      end

      ##
      # Returns the requested rate.
      #
      # It also flushes all the rates when and if they are expired.
      #
      # @param [String, Symbol, Currency] from Currency to convert from
      # @param [String, Symbol, Currency] to Currency to convert to
      #
      # @return [Float] The requested rate.
      #
      # @example
      #   @bank = GoogleCurrency.new  #=> <Money::Bank::GoogleCurrency...>
      #   @bank.get_rate(:USD, :EUR)  #=> 0.776337241
      def get_rate(from, to)
        expire_rates
        store.get_rate(from, to) || store.add_rate(from, to, fetch_rate(from, to))
      end

      ##
      # Flushes all the rates if they are expired.
      #
      # @return [Boolean]
      def expire_rates
        if self.class.ttl_in_seconds && self.class.rates_expiration <= Time.now
          flush_rates
          self.class.refresh_rates_expiration!
          true
        else
          false
        end
      end

      private

      def shared_rates_store
        self.class.shared_rates_store
      end

      def shared_rates_store_expires_in
        self.class.shared_rates_store_expires_in
      end

      def rate_key(c1,c2)
        [c1, c2].join(':').upcase
      end

      ##
      # Queries for the requested rate and returns it.
      #
      # @param [String, Symbol, Currency] from Currency to convert from
      # @param [String, Symbol, Currency] to Currency to convert to
      #
      # @return [BigDecimal] The requested rate.
      def fetch_rate(from, to)
        from, to = Currency.wrap(from), Currency.wrap(to)
        rate = read_and_extract_rate(from, to)
        rate = 1/read_and_extract_rate(to, from) if (rate < 0.1)
        rate
      end
      
      def read_and_extract_rate(c1, c2)
        rate = shared_rates_store ? shared_rates_store.read(rate_key(c1, c2)) : nil

        unless rate
          rate = bombproof_extract_rate(c1, c2)
          raise "Fack, totally bombed trying to get the rate for #{c1} -> #{c2}" if rate.nil?
          shared_rates_store.write(rate_key(c1, c2), rate, expires_in: shared_rates_store_expires_in||3600) if rate && shared_rates_store
        end

        rate
      end

      def bombproof_extract_rate(c1, c2)
        extract_rate(read_rate(c1, c2))
      rescue UnknownRate, GoogleCurrencyFetchError
        HardcodedDefaultRates.new(c1, c2).rate
      end

      class HardcodedDefaultRates
        def initialize(c1, c2)
          @c1 = c1
          @c2 = c2
        end

        def rate
          rate = rate_lookup(key(@c1, @c2))
          rate = 1/rate_lookup(key(@c2, @c1)) if (rate.nil? && !rate_lookup(key(@c2, @c1)).nil?)
          rate
        end

        def key(c1, c2)
          [c1, c2].join(':')
        end

        def rate_lookup(key)
          {
              'USD:VND' => 22690.00
          }[key]
        end
      end

      def read_rate(c1, c2)
        retryable(tries: 3, on: [Errno::ECONNREFUSED, OpenURI::HTTPError, Errno::ENETUNREACH]) do
          build_uri(c1, c2).read
        end
      end

      ##
      # Build a URI for the given arguments.
      #
      # @param [Currency] from The currency to convert from.
      # @param [Currency] to The currency to convert to.
      #
      # @return [URI::HTTP]
      def build_uri(from, to)
        URI::HTTP.build(
          :host  => SERVICE_HOST,
          :path  => SERVICE_PATH,
          :query => "a=1&from=#{from.iso_code}&to=#{to.iso_code}"
        )
      end

      ##
      # Takes the response from Google and extract the rate.
      #
      # @param [String] data The google rate string to decode.
      #
      # @return [BigDecimal]
      def extract_rate(data)
        case data
        when /<span class=bld>(\d+\.?\d*) [A-Z]{3}<\/span>/
          BigDecimal($1)
        when /Could not convert\./
          raise UnknownRate
        else
          raise GoogleCurrencyFetchError
        end
      end

      # * :tries - Number of retries to perform. Defaults to 1.
      # * :on - The exceptions on which a retry will be performed. Defaults to Exception, which retries on any Exception.
      #
      # Example
      # =======
      #   retryable(tries: 1, on: OpenURI::HTTPError) do
      #     # your code here
      #   end
      #
      def retryable(options = {}, &block)
        opts = { tries: 1, on: [Exception], sleep: 0 }.merge(options)
        retry_exceptions, retries, sleep = opts[:on], opts[:tries], opts[:sleep]

        begin
          return yield
        rescue *retry_exceptions
          if (retries -= 1) > 0
            sleep(sleep)
            sleep += 1
            retry
          end
        end

        yield
      end
    end
  end
end
